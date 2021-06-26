//
//  SentimentAllocator.m
//  joey
//
//  Created by Chirath Kumarasiri on 2/12/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "SentimentAllocator.h"
#import "Venue.h"
#import "UserPreferenceHandler.h"
#import "TipClassifier.h"

@interface SentimentAllocator()

@property (strong, nonatomic) NSMutableArray *trends;
@property (strong, nonatomic) NSMutableArray *weights;

@end

@implementation SentimentAllocator

-(void)initializeSentimentAllocatorOnCompletion:(void (^)(BOOL))completionBlock {
    
    UserPreferenceHandler *userPreferenceHandler = [[UserPreferenceHandler alloc] init];
    
    if (userPreferenceHandler.userPreference.supervised){
        
        [self allocateWeightsToIdentifiedAspectsFromClassifier];

    } else {
        
        [self initializeLexiconWeights];
        [self allocateWeightsToIdentifiedAspectsFromLexicon];
    }
    
    [self calculateVenueSentiment];
    
    completionBlock (YES);
}

#pragma mark - Classifier Methods

-(void) allocateWeightsToIdentifiedAspectsFromClassifier {
    
    TipClassifier *classifier = [[TipClassifier alloc] init];
    [classifier trainPolarityCalssifier];
    
    RLMRealm *defaultRealm = [RLMRealm defaultRealm];

    RLMResults *identifiedAspects = [IdentifiedAspect allObjects];
    
    for (IdentifiedAspect *identifiedAspect in identifiedAspects){
        
        NSArray *trends = [identifiedAspect.trend componentsSeparatedByString:@" "];
        NSInteger finalWeight = 0;
        
        for (NSString *trend in trends) {
            
            NSString *string = [NSString stringWithFormat:@"%@ %@", trend, identifiedAspect.aspect];
            
            NSString *polarity = [classifier polarityDetectorWithString:string];
            
            NSInteger aspectWeight = 0;
            
            if ([polarity isEqualToString:@"POSITIVE"]){
                
                aspectWeight = 1;
                
            } else {
                
                aspectWeight = -1;
            }
            
            finalWeight += aspectWeight;
            
            [defaultRealm beginWriteTransaction];
            identifiedAspect.aspectWeight = finalWeight;
            [defaultRealm commitWriteTransaction];
        }
        
        [self calculateTipSentimentWith:identifiedAspect.tipId andAspectWeight:identifiedAspect.aspectWeight];
    }
}

#pragma mark - Lexicon Methods

-(void)initializeLexiconWeights {
    
    NSString *fileText = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AFINN-111" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *trendWithWeights = [fileText componentsSeparatedByString:@"\n"];
    
    self.trends = [NSMutableArray new];
    self.weights = [NSMutableArray new];
    
    for (NSString *trendWithWeight in trendWithWeights){
        
        NSArray *singleTrendAndWeight = [trendWithWeight componentsSeparatedByString:@"\t"];
        
        [self.trends addObject:singleTrendAndWeight[0]];
        [self.weights addObject:singleTrendAndWeight[1]];
    }
}

-(void)allocateWeightsToIdentifiedAspectsFromLexicon {
    
    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
    
    RLMResults <IdentifiedAspect *> *identifiedAspects = [IdentifiedAspect allObjects];
    
    for (IdentifiedAspect *identifiedAspect in identifiedAspects){
        
            NSArray *trends = [identifiedAspect.trend componentsSeparatedByString:@" "];
            NSInteger finalWeight = 0;
            
            for (NSString *trend in trends) {
                
                if ([_trends containsObject:trend]){
                    
                    NSInteger indexOfTheTrend = [_trends indexOfObject:trend];
                    finalWeight += (int)[[_weights objectAtIndex:indexOfTheTrend] integerValue];
                    
                } else {
                    
                    finalWeight += 0;
                }
                
                [defaultRealm beginWriteTransaction];
                identifiedAspect.aspectWeight  = finalWeight;
                [defaultRealm commitWriteTransaction];
            }
            
            [self calculateTipSentimentWith:identifiedAspect.tipId andAspectWeight:identifiedAspect.aspectWeight];
        }
}

#pragma mark - Common Methods

-(void)calculateTipSentimentWith:(NSString *) tipId andAspectWeight:(NSInteger) weight {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tipId == %@", tipId];
    
    RLMResults *tips = [Tip objectsWithPredicate:predicate];
    Tip *tipForId = [tips firstObject];
    
    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
    [defaultRealm beginWriteTransaction];
    tipForId.tipSentiment += weight;
    [defaultRealm commitWriteTransaction];
}

-(void)calculateVenueSentiment {
    
    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
    RLMResults <Venue *> *venues = [Venue allObjects];
    
    for (Venue *venue in venues){
        
        NSInteger finalVenueSentiment = 0;
        
        for (Tip *tip in venue.tips){
            
            finalVenueSentiment += tip.tipSentiment;
        }
        
        [defaultRealm beginWriteTransaction];
        venue.venueSentiment += finalVenueSentiment;
        [defaultRealm commitWriteTransaction];
    }
}

@end
