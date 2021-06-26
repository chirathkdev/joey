//
//  ViewController.m
//  joey
//
//  Created by Chirath Kumarasiri on 1/23/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "ViewController.h"
#import "FoursquareHandler.h"
#import "TipProcessor.h"
#import <Realm/Realm.h>
#import "Venue.h"
#import "TipClassifier.h"
#import "SentimentAllocator.h"
#import "SearchViewController.h"

@interface ViewController ()

@property (nonatomic,strong) FoursquareHandler *foursquareHandler;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@property (nonatomic, copy) NSString *sampleTip1;
@property (nonatomic, copy) NSString *sampleTip2;
@property (nonatomic, copy) NSString *sampleTip3;
@property (nonatomic, copy) NSString *sampleTip4;
@property (nonatomic, copy) NSString *sampleTip5;

@property (weak, nonatomic) IBOutlet UIButton *restaurantAnalysisView;

-(IBAction)processReview:(id)sender;
-(IBAction)restaurantAnalysisView:(id)sender;
-(IBAction)sampleTipProcess:(id)sender;


-(IBAction)searchView:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.latitude = 6.8652715;
    self.longitude = 79.8598505;
    
    self.sampleTip1 = @"Healthy vegetarian indian specially south indian food in crowded restaurant Tasty masala dosai and rotti";
    
    self.sampleTip2 = @"RedPrawnCurry it is very delicious";
    
    self.sampleTip3 = @"Shawarma is good. Burgers are ok. Too much sauce/cheese sometimes and way too much oil";
    
    self.sampleTip4 = @"Amazing burgers for amazing prices";
    
    //Red curry and egg fried rice is good. Medium potion of rice enough for 2. Red curry enough for 4
    
    //yummyyyyyyyyyyyyyy
    
    
    //nice atmosphere friendly staff Crabs and EggFriedRice delicious
    
    //super SpicyTomYum and too sweet SweetCornSoup
    
    //love the HotButterCuttlefish
    
    //nice place. which needs more improvement in detailing.
    
    self.foursquareHandler = [FoursquareHandler new];
    
//    NSLog(@"%@", _sampleTip1);
    NSLog(@"%@",[RLMRealmConfiguration defaultConfiguration].fileURL);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Methods

- (IBAction)train:(id)sender{
    
    TipClassifier *classifier = [[TipClassifier alloc] init];;
    [classifier initializeClassifier];
}

- (IBAction)processReview:(id)sender{
    
    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
    
    RLMResults <IdentifiedAspect *> *identifiedAspects = [IdentifiedAspect allObjects];
    
    [defaultRealm beginWriteTransaction];
    [defaultRealm deleteObjects:identifiedAspects];
    [defaultRealm commitWriteTransaction];
    
    TipProcessor *processor = [[TipProcessor alloc] init];;
    [processor initializeProcessorOnCompletion:^(BOOL success) {
        
        
    }];
}

- (IBAction)calculateSentiment:(id)sender{
    
    SentimentAllocator *allocator = [[SentimentAllocator alloc] init];;
    [allocator initializeSentimentAllocatorOnCompletion:^(BOOL success) {
        
    }];
}

-(IBAction)restaurantAnalysisView:(id)sender{
    
    UITableViewController *restaurantAnalysisViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RestaurantAnalysisViewController"];
    [self.navigationController pushViewController:restaurantAnalysisViewController animated:YES];
}

-(IBAction)searchView:(id)sender{
    
    UIViewController *searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self.navigationController pushViewController:searchViewController animated:YES];
    
}

- (IBAction)sampleTipProcess:(id)sender{
    
    NSLog(@"%@", _sampleTip2);
    NSString *rawText = _sampleTip2;
    
    NSMutableArray *sentences = [NSMutableArray new];
    
    [rawText enumerateSubstringsInRange:NSMakeRange(0,[rawText length])
                                options:NSStringEnumerationBySentences | NSStringEnumerationLocalized
                             usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                                 
                                 
                                 [sentences addObject:substring];
                                 
                             }];
    
    NSLog(@"%@", sentences);
    
    
    //Initialize TokensAndTags Dictionary
//    NSMutableDictionary *tokensAndTags = [[NSMutableDictionary new] init];
    NSMutableDictionary *adjectiveDictionary = [NSMutableDictionary new];
    

    NSMutableArray  *nounTokenArray = [NSMutableArray new];
    
    //Initialize Tagger With Options
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
    
    for (NSString *sentence in sentences){
        
        tagger.string = sentence;
        
        [tagger enumerateTagsInRange:NSMakeRange(0, [sentence length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
            
            NSString *token = [sentence substringWithRange:tokenRange];
            NSLog(@"%@: %@", token, tag);
//            
//            [tokenArray addObject:token];
//            [tagArray addObject:tag];
            
            if ([tag  isEqual: @"Adjective"]){
                
                if (![adjectiveDictionary objectForKey:@"Adjective"]){
                    
                    [adjectiveDictionary setObject:token forKey:tag];
                    
                } else {
                    
                    NSString *newAdjectiveToken = [NSString stringWithFormat:@"%@ %@" , [adjectiveDictionary objectForKey:@"Adjective"] , token];
                    [adjectiveDictionary setObject:newAdjectiveToken forKey:tag];
                }
                
            } else if ([tag  isEqual: @"Noun"] || [tag isEqualToString:@"PlaceName"]){
                
                //                    NSLog(@"%@: %@", token, tag);
                
                if ([adjectiveDictionary objectForKey:@"Adjective"] != nil){
                    
                    NSString *adjective = [[adjectiveDictionary objectForKey:@"Adjective"] lowercaseString];
                    NSLog(@"%@" , token);
                    NSLog(@"%@" , adjective);
                    [adjectiveDictionary removeAllObjects];
                    
                } else {
                    
                    [nounTokenArray addObject:token];
                }
            }
        }];
        
        for (NSString *noun in nounTokenArray){
            
            if ([adjectiveDictionary objectForKey:@"Adjective"]){
                
                NSLog(@"%@" , noun);
                NSLog(@"%@" , [adjectiveDictionary objectForKey:@"Adjective"]);
            }
        }
        [nounTokenArray removeAllObjects];
        [adjectiveDictionary removeAllObjects];
    }
    
    
////    NSMutableArray *selectedTokensAndTagsArray = [NSMutableArray new];
//    NSMutableArray  *tokenArray = [NSMutableArray new];
//    NSMutableArray  *tagArray = [NSMutableArray new];
//
//    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
//    
//    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
//    
//    tagger.string = _sampleTip1;
//    
//    [tagger enumerateTagsInRange:NSMakeRange(0, [_sampleTip1 length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
//        
//        NSString *token = [_sampleTip1 substringWithRange:tokenRange];
//        
////        NSString *tokenWithTag = [NSString stringWithFormat:@"%@:%@", token, tag];
//        
//        NSLog(@"%@: %@", token, tag);
//        
//        if ([tag  isEqual: @"Noun"] || [tag isEqualToString:@"PlaceName"] || [tag  isEqual: @"Adjective"] || [tag isEqualToString:@"Adverb"] || [tag  isEqual: @"Otherword"]) {
//            
//            [tokenArray addObject:token];
//            [tagArray addObject:tag];
////            [selectedTokensAndTagsArray addObject:tokenWithTag];
//            
//        }
//    }];
//    
//    [self trimAspectWithTokenArray:tokenArray andTagArray:tagArray];
}

-(void) trimAspectWithTokenArray:(NSArray *) tokenArray andTagArray:(NSArray *) tagArray{
    
//    NSMutableDictionary *tokensAndTags = [[NSMutableDictionary alloc] init];
//    
//    for (int x=0; x <= [tokenArray count]; x++){
////        
////        NSString *token = [[item componentsSeparatedByString:@":"] objectAtIndex:0];
////        NSString *tag = [[item componentsSeparatedByString:@":"] objectAtIndex:1];
//        
//        NSString *token = [tokenArray objectAtIndex:x];
//        NSString *tag = [tagArray objectAtIndex:x];
//        
//        [tokensAndTags setValue:token forKey:tag];
//        
//        if ([tag  isEqual: @"Noun"] || [tag isEqualToString:@"PlaceName"] || [tag  isEqual: @"Otherword"]){
//            
//            if ([tokensAndTags count] == 1){
//                
//                NSMutableArray *copyTagArray = [tagArray mutableCopy];
////                [copyTagArray removeObjectAtIndex:1];
//                NSUInteger index = [copyTagArray indexOfObject:@"Noun"];
//                
//                for (int y=1; y <index; y++){
//                    
//                    
//                }
//                
//                 [tokensAndTags setValue:token forKey:tag];
//                
//            
//            } else {
//                
//                for (id key in tokensAndTags){
//                    //
//                    //                if ([key isEqualToString:@"Adjective"]){
//                    //
//                    //
//                    //                }
//                    //
//                    //                if (tokensAndTags){
//                    //
//                    //                    if ([tokensAndTags count])
//                    //                        
//                    //                        [tokensAndTags removeAllObjects];
//                    //                } else {
//                    //                    
//                    //                }
//                    //            }
//                
//            }
//            
//        
//    }
//    
//    //Noun Verb Adjective
//    
//    //Adjective Noun
//    
//    //Adverb Adjective Noun
//    
//    //Verb Adverb Noun
//    
//    //Adjective Adverb Adjective Noun
}
    


@end
