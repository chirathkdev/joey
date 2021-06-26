//
//  FoursquareHandler.m
//  joey
//
//  Created by Chirath Kumarasiri on 1/23/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "FoursquareHandler.h"
#import "Venue.h"
#import "VenueInfo.h"

@implementation FoursquareHandler

#define FOURSQUARE_BASE_URL @"https://api.foursquare.com"
#define FOURSQUARE_VENUE_SEARCH_URL @"/v2/venues/explore"
#define FOURSQUARE_CLIENT_ID @"LXMKYHXDUHKWJIHNUBT5WX3TJMWLMCORYRB1R3IPBRARVWPI"
#define FOURSQUARE_CLIENT_SECRET @"BU4CNEMZ5LQLMIF0JJ4NXKJQWW151AWOKKLT0UZG4I0I2IQP"
//#define SECTION @"food"
//#define QUERY @"thai"

#define FOURSQUARE_VENUE_ID_URL @"https://api.foursquare.com/v2/venues/"
#define FOURSQUARE_TIPS_SEARCH_URL @"/tips?sort=recent"

#pragma mark RequestVenues API CALL

-(void)retrieveVenuesNearLatitude:(double)latitude andLongitude:(double)longitude andQuery:(NSString *) query onCompletion:(void(^)(BOOL success, NSError *error)) completionBlock {
    
    _isRetrievingNearByLocations = YES;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMDD"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?ll=%f,%f&client_id=%@&client_secret=%@&v=%@&limit=%d&query=%@",FOURSQUARE_BASE_URL,FOURSQUARE_VENUE_SEARCH_URL,latitude,longitude,FOURSQUARE_CLIENT_ID,FOURSQUARE_CLIENT_SECRET,date,10,query]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setTimeoutInterval:30];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      _isRetrievingNearByLocations = NO;
                                      
                                      if (!error) {
                                          
                                          NSError *jsonError;
                                          id jsonDictionaryOrArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                          
                                          if(!jsonError) {
                                              NSDictionary *parentDic = [jsonDictionaryOrArray objectForKey:@"response"];
                                              
                                              NSArray *groups = [parentDic objectForKey:@"groups"];
                                              
                                              NSArray *items = [groups valueForKey:@"items"][0];
                                              
                                              [self saveVenueItems:items];
                                              
                                              completionBlock (YES,nil);
                                          }
                                          else {
                                              completionBlock(NO,jsonError);
                                          }
                                          
                                      }
                                      else {
                                          completionBlock(NO,error);
                                      }
                                      
                                  }];
    
    [task resume];
}

#pragma mark SaveVenueItems Method

-(void) saveVenueItems:(NSArray*)venueItemData {
    
    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
    
    for (NSDictionary *venueItemInfo in [venueItemData valueForKey:@"venue"]) {
        
        VenueInfo *venueInfo = [[VenueInfo alloc] init];
        venueInfo.name = [venueItemInfo objectForKey:@"name"];
        venueInfo.foursquareId = [venueItemInfo objectForKey:@"id"];
        
        NSDictionary *locationInfo = [venueItemInfo objectForKey:@"location"];
        venueInfo.latitude = [[locationInfo objectForKey:@"lat"] stringValue];
        venueInfo.longitude = [[locationInfo objectForKey:@"lng"] stringValue];
        venueInfo.distance = [locationInfo objectForKey:@"distance"];
        
        NSString *country = [locationInfo objectForKey:@"country"];
        
        NSArray *addressInfo = [locationInfo objectForKey:@"formattedAddress"];
        
        if (addressInfo && [addressInfo respondsToSelector:@selector(objectAtIndex:)]) {
            
            NSMutableString *addressStr = [NSMutableString string];
            
            if (addressInfo.count > 0) {
                [addressStr appendString:[addressInfo objectAtIndex:0]];
            }
            
            if (addressInfo.count > 1){
                [addressStr appendString:@" "];
                [addressStr appendString:[addressInfo objectAtIndex:1]];
            }
            
            [addressStr replaceOccurrencesOfString:country withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, addressStr.length)];
            
            venueInfo.address = addressStr;
        }
        
        NSArray *categories = [venueItemInfo objectForKey:@"categories"];
        
        if (categories && [categories respondsToSelector:@selector(objectAtIndex:)]) {
            
            if (categories.count > 0) {
                NSDictionary *categoryInfo = [categories objectAtIndex:0];
                NSDictionary *iconInfo = [categoryInfo objectForKey:@"icon"];
                
                venueInfo.imageURL = [NSString stringWithFormat:@"%@bg_88%@",[iconInfo objectForKey:@"prefix"],[iconInfo objectForKey:@"suffix"]];
                
                venueInfo.category = [categoryInfo objectForKey:@"shortName"];
            }
        }
        
        VenueStat *venueStat = [[VenueStat alloc] init];
        
        NSDictionary *stats = [venueItemInfo objectForKey:@"stats"];
        venueStat.checkinsCount = [stats objectForKey:@"checkinsCount"];
        venueStat.usersCount = [stats objectForKey:@"usersCount"];
        venueStat.tipcount = [stats objectForKey:@"tipCount"];
        
        venueStat.priceTier = [[venueItemInfo objectForKey:@"price"] objectForKey:@"tier"];
        
        venueStat.rating = [venueItemInfo objectForKey:@"rating"];
        venueStat.isOpen = [[venueItemInfo objectForKey:@"hours"] objectForKey:@"isOpen"];
        venueStat.hereNow = [[venueItemInfo objectForKey:@"hereNow"] objectForKey:@"count"];
        
        Venue *venue = [[Venue alloc] init];
        venue.venueId = venueInfo.foursquareId;
        venue.venueInfo = venueInfo;
        venue.venueStat = venueStat;
        
        
        
        [defaultRealm beginWriteTransaction];
        [defaultRealm addObject:venue];
        [defaultRealm commitWriteTransaction];
    }
}

#pragma mark RequestTips API CALL

-(void)retrieveTipsForVenuesOnCompletion:(void(^)(BOOL success, NSError *error)) completionBlock {
    
    //    _isRetrievingNearByLocations = YES;
    
    //Creating a group for loop of API Calls
    dispatch_group_t group = dispatch_group_create();
    
    RLMResults *venues = [Venue allObjects];
    
    for (Venue *venue in venues){
        
        NSString *venueId = venue.venueId;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYYMMDD"];
        NSString *date = [formatter stringFromDate:[NSDate date]];
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@&client_id=%@&client_secret=%@&v=%@",FOURSQUARE_VENUE_ID_URL,venueId,FOURSQUARE_TIPS_SEARCH_URL,FOURSQUARE_CLIENT_ID,FOURSQUARE_CLIENT_SECRET,date]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        [request setTimeoutInterval:30];
        NSURLSession *session = [NSURLSession sharedSession];
        
        dispatch_group_enter(group);
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          //                                      _isRetrievingNearByLocations = NO;
                                          
                                          if (!error) {
                                              
                                              NSError *jsonError;
                                              id jsonDictionaryOrArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                              
                                              if(!jsonError) {
                                                  NSDictionary *parentDic = [jsonDictionaryOrArray objectForKey:@"response"];
                                                  
                                                  NSArray *tips = [[parentDic objectForKey:@"tips"] valueForKey:@"items"];
                                                  
                                                  [self saveTips:tips forVenue:venueId];
                                                  
                                                  dispatch_group_leave(group);
//                                                  completionBlock (YES,nil);
                                                  
                                              } else {
                                                  dispatch_group_leave(group);
//                                                  completionBlock(NO,jsonError);
                                              }
                                              
                                          }  else {
                                              dispatch_group_leave(group);
//                                              completionBlock(NO,error);
                                          }
                                      }];
        [task resume];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completionBlock (YES,nil);
    });
}

#pragma mark SaveTips Method

-(void) saveTips:(NSArray*)tips forVenue:(NSString *)venueId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"venueInfo.foursquareId == %@", venueId];
    
    RLMResults *venues = [Venue objectsWithPredicate:predicate];
    Venue *venue = [venues firstObject];
    
    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
    
    for (NSDictionary *tipInfo in tips) {
        
        Tip *tip = [[Tip alloc] init];
        
        tip.tipId = [tipInfo objectForKey:@"id"];
        tip.tipText = [tipInfo objectForKey:@"text"];
        
        NSString *normalizedTip = [self normalizeTipText:[tipInfo objectForKey:@"text"]];
        tip.normalizedTipText = [normalizedTip stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        tip.createdAt = [tipInfo objectForKey:@"createdAt"];
        tip.likes = [[tipInfo objectForKey:@"likes"] objectForKey:@"count"];
        
        tip.agreeCount = [tipInfo objectForKey:@"agreeCount"];
        tip.disagreeCount = [tipInfo objectForKey:@"disagreeCount"];
        
        [defaultRealm beginWriteTransaction];
        [venue.tips addObject:tip];
        [defaultRealm commitWriteTransaction];
    }
}

-(NSString *)normalizeTipText:(NSString *) rawText{
    

    NSString *normalizedTip = @"";
    
    NSArray *sentences = [self breakSentences:rawText];
    
    for (NSString *sentence in sentences){
        
        NSString *normalizedSentence = @"";
       
        NSMutableString *string = (NSMutableString *)[self removeUnicode:sentence];
        
        CFStringTransform((__bridge CFMutableStringRef) string, NULL, kCFStringTransformStripCombiningMarks, NO);
        
        //    CFStringTransform((__bridge CFMutableStringRef) string, NULL, kCFStringTransformToUnicodeName, NO);
        
        CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(NULL, (__bridge CFStringRef) string, CFRangeMake(0, string.length), kCFStringTokenizerUnitWord, CFLocaleCopyCurrent());
        
        CFStringTokenizerTokenType tokenType = kCFStringTokenizerTokenNone;
        
        while ((tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)) != kCFStringTokenizerTokenNone){
            
            CFRange tokenRange  = CFStringTokenizerGetCurrentTokenRange(tokenizer);
            
            CFStringRef token = CFStringCreateWithSubstring(kCFAllocatorDefault, (__bridge CFStringRef) string, tokenRange);
            
            NSString *stringForToken = [NSString stringWithFormat:@"%@ ",(__bridge NSString *)(token)];
            
            normalizedSentence = [normalizedSentence stringByAppendingString:[stringForToken lowercaseString]];
        }
        
        normalizedSentence = [normalizedSentence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                              
        normalizedTip = [normalizedTip stringByAppendingString:[NSString stringWithFormat:@"%@. " , normalizedSentence]];
    }
    
    return normalizedTip;
}

-(NSArray *)breakSentences:(NSString *) rawText{
    
    NSMutableArray *sentences = [NSMutableArray new];
    
    [rawText enumerateSubstringsInRange:NSMakeRange(0,[rawText length])
                                options:NSStringEnumerationBySentences | NSStringEnumerationLocalized
                             usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                                 [sentences addObject:substring];
                             }];
    return sentences;

}

-(NSString *)removeUnicode:(NSString *) string{
    
    NSMutableString *asciiCharacters = [NSMutableString string];
    
    for (int i = 32; i < 127; i++)  {
        [asciiCharacters appendFormat:@"%c", i];
    }
    
    NSCharacterSet *nonAsciiCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:asciiCharacters] invertedSet];
    
    string = [[string componentsSeparatedByCharactersInSet:nonAsciiCharacterSet] componentsJoinedByString:@""];
    
//    NSLog(@"%@", string);

    return string;
}

@end
