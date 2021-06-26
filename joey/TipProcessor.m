//
//  TipProcessor.m
//  joey
//
//  Created by Chirath Kumarasiri on 1/30/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "TipProcessor.h"
#import "Venue.h"
#import "TipClassifier.h"
#import "UserPreferenceHandler.h"

@interface TipProcessor()

@property (strong, nonatomic) UserPreferenceHandler *userPreferenceHandler;

@end

@implementation TipProcessor

-(void) initializeProcessorOnCompletion:(void(^)(BOOL success)) completionBlock{
    
    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
    
    RLMResults <IdentifiedAspect *> *identifiedAspects = [IdentifiedAspect allObjects];
    
    [defaultRealm beginWriteTransaction];
    [defaultRealm deleteObjects:identifiedAspects];
    [defaultRealm commitWriteTransaction];
    
    //    NSString *fileText = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"thai" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    //
    //    self.dishList = [[NSMutableArray alloc]initWithArray:[fileText componentsSeparatedByString:@"\r\n"]];
    //    [self.dishList removeLastObject];
    
    self.userPreferenceHandler = [[UserPreferenceHandler alloc] init];
    
    [self processTip];
    
    completionBlock (YES);
}

-(void)processTip {
    
    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
    
    //Initialize Tagger With Options
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
    
    //Get all Venues
    RLMResults <Venue *> *venues = [Venue allObjects];
    
    for (Venue *venue in venues){
        
        for (Tip *tip in venue.tips){
            
            NSString *tipWithDishNames = (NSMutableString *)[self checkForDishNames:tip.normalizedTipText];
            
            [defaultRealm beginWriteTransaction];
            tip.tipWithDishNameText  = tipWithDishNames;
            [defaultRealm commitWriteTransaction];
            
            NSMutableArray *sentences = (NSMutableArray *)[tipWithDishNames componentsSeparatedByString:@"."];
            [sentences removeLastObject];
            
            for (NSString *sentence in sentences){
                
                NSMutableDictionary *adjectiveDictionary = [NSMutableDictionary new];
                NSMutableArray  *nounTokenArray = [NSMutableArray new];
                tagger.string = sentence;
                
                [tagger enumerateTagsInRange:NSMakeRange(0, [sentence length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                    
                    NSString *token = [sentence substringWithRange:tokenRange];
                    
                    if ([tag  isEqual: @"Adjective"]){
                        
                        if (![adjectiveDictionary objectForKey:@"Adjective"]){
                            
                            [adjectiveDictionary setObject:token forKey:tag];
                            
                        } else {
                            
                            NSString *newAdjectiveToken = [NSString stringWithFormat:@"%@ %@" , [adjectiveDictionary objectForKey:@"Adjective"] , token];
                            [adjectiveDictionary setObject:newAdjectiveToken forKey:tag];
                        }
                        
                    } else if ([tag  isEqual: @"Noun"] || [tag isEqualToString:@"PlaceName"]){
                        
                        if ([adjectiveDictionary objectForKey:@"Adjective"] != nil){
                            
                            NSString *aspect = token;
                            NSString *trend = [[adjectiveDictionary objectForKey:@"Adjective"] lowercaseString];
                            
                            IdentifiedAspect *identifiedAspect = [[IdentifiedAspect alloc] init];
                            
                            identifiedAspect = [self createIdentifiedAspectWithTipId:tip.tipId andAspect:aspect andTrend:trend];
                            
                            [adjectiveDictionary removeAllObjects];
                            
                            [defaultRealm beginWriteTransaction];
                            [venue.identifiedAspects addObject:identifiedAspect];
                            [defaultRealm commitWriteTransaction];
                            
                        } else {
                            
                            [nounTokenArray addObject:token];
                        }
                    }
                }];
                
                for (NSString *noun in nounTokenArray){
                    
                    if ([adjectiveDictionary objectForKey:@"Adjective"]){
                        
                        NSString *aspect = noun;
                        NSString *trend = [[adjectiveDictionary objectForKey:@"Adjective"] lowercaseString];
                        
                        IdentifiedAspect *identifiedAspect = [[IdentifiedAspect alloc] init];
                        
                        identifiedAspect = [self createIdentifiedAspectWithTipId:tip.tipId andAspect:aspect andTrend:trend];
                        
                        [defaultRealm beginWriteTransaction];
                        [venue.identifiedAspects addObject:identifiedAspect];
                        [defaultRealm commitWriteTransaction];
                        
                        
                        //                        NSLog(@"%@" , noun);
                        //                        NSLog(@"%@" , [adjectiveDictionary objectForKey:@"Adjective"]);
                    }
                }
                [nounTokenArray removeAllObjects];
                [adjectiveDictionary removeAllObjects];
            }
        }
    }
}


-(NSString *)checkForDishNames:(NSString *) string{
    
    //    BOOL addTipToClassifier = NO;
    
    for (NSString *dish in _userPreferenceHandler.fullDishList){
        
        NSRange searchResult = [string rangeOfString:dish options:NSCaseInsensitiveSearch];
        
        if (searchResult.location != NSNotFound) {
            
            //            addTipToClassifier = YES;
            
            NSString *dishName = [dish stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            string = [string stringByReplacingCharactersInRange:searchResult withString:dishName];
            
            //add to model
        }
    }
    
    //    if (addTipToClassifier){
    //        TipClassifier *classifier = [[TipClassifier alloc] init];
    //    }
    return string;
    
}

-(IdentifiedAspect *) createIdentifiedAspectWithTipId:(NSString *) tipId andAspect:(NSString *) aspect andTrend:(NSString *) trend {
    
    IdentifiedAspect *identifiedAspect = [[IdentifiedAspect alloc] init];
    
    identifiedAspect.tipId = tipId;
    
    NSString *aspectWithWhiteSpace = [self getAspectWithWhiteSpace:aspect];
    
    if ([_userPreferenceHandler.userDishList containsObject:aspectWithWhiteSpace]){
        
        identifiedAspect.aspectTypeMain = @"USER";
        
        
    } else if ([_userPreferenceHandler.cuisineDishList containsObject:aspectWithWhiteSpace]){
        
        identifiedAspect.aspectTypeMain = @"CUISINE";
        
    } else {
        
        identifiedAspect.aspectTypeMain = @"GENERAL";
    }
    
    identifiedAspect.aspect = aspect;
    identifiedAspect.trend = trend;
    
    return identifiedAspect;
}

-(NSString *) getAspectWithWhiteSpace:(NSString *) aspect{
    
    NSMutableString *aspectWithWhiteSpace = [NSMutableString string];
    
    for (NSInteger i=0; i < aspect.length; i++){
        
        NSString *ch = [aspect substringWithRange:NSMakeRange(i, 1)];
        
        if ([ch rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound) {
            
            [aspectWithWhiteSpace appendString:@" "];
        }
        
        [aspectWithWhiteSpace appendString:ch];
    }
    
    aspectWithWhiteSpace = (NSMutableString *)[aspectWithWhiteSpace stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return aspectWithWhiteSpace;
}

@end
