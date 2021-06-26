//
//  TipClassifier.m
//  joey
//
//  Created by Chirath Kumarasiri on 2/8/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "TipClassifier.h"
#import "Venue.h"
#import "TrainingDataHandler.h"

@interface TipClassifier()

@property (strong, nonatomic) ParsimmonNaiveBayesClassifier *categoryClassifier;

@property (strong, nonatomic) ParsimmonNaiveBayesClassifier *polarityClassifier;

@property (strong, nonatomic) NSArray *trainingDataSet;

@end

@implementation TipClassifier

#pragma mark - Initializer

- (instancetype)init{
    
    self = [super init];
    if (self) {
        
        TrainingDataHandler *trainingDataHandler = [[TrainingDataHandler alloc] init];
        
        self.trainingDataSet = [trainingDataHandler initializeDataWithXMLParser];
    
        self.categoryClassifier = [[ParsimmonNaiveBayesClassifier alloc] init];
    }
    return self;
}

-(void)initializeClassifier {
    

    
//    [self train:trainingDataSet];
//    
//    [self polarityDetector];
    
}

#pragma mark - Training

-(void)trainCategoryClassifier {
    
    //    AMBIENCE = 183;
    //    DRINKS = 75;
    //    FOOD = 729;
    //    LOCATION = 20;
    //    RESTAURANT = 379;
    //    SERVICE = 268;
    
    int food = 0;
    int ambience = 0;
    int restaurant = 0;
    int service = 0;
    
    for (NSDictionary *data in _trainingDataSet){
        
        for (NSDictionary *opinion in [data objectForKey:@"opinions"]){
            
            NSArray *entityWithAttribute = [[opinion objectForKey:@"opinionCategory"] componentsSeparatedByString:@"#"];
            
            if ([entityWithAttribute[0] isEqualToString:@"FOOD"] && food < 183){
                
                [_categoryClassifier trainWithText:[data objectForKey:@"text"] category:@"FOOD"];
                food++;
                
            } else if ([entityWithAttribute[0] isEqualToString:@"SERVICE"] && service < 183){
                
                [_categoryClassifier trainWithText:[data objectForKey:@"text"] category:@"SERVICE"];
                service++;
                
            } else if ([entityWithAttribute[0] isEqualToString:@"AMBIENCE"] && ambience < 183){
                
                [_categoryClassifier trainWithText:[data objectForKey:@"text"] category:@"AMBIENCE"];
                ambience++;
                
            } else if ([entityWithAttribute[0] isEqualToString:@"RESTAURANT"] && restaurant < 183){
                
                [_categoryClassifier trainWithText:[data objectForKey:@"text"] category:@"RESTAURANT"];
                restaurant++;
                
            }
        }
    }
    
}

-(void)trainPolarityCalssifier {
    
     self.polarityClassifier = [[ParsimmonNaiveBayesClassifier alloc] init];
    
//        negative = 403;
//        neutral = 53;
//        positive = 1198;
    
        int positive = 0;
        int negative = 0;
//        int neutral = 0;

    for (NSDictionary *data in _trainingDataSet){
        
        for (NSDictionary *opinion in [data objectForKey:@"opinions"]){
            
            if ([[opinion objectForKey:@"opinionPolarity"] isEqualToString:@"positive"] && positive < 403){
                
                [_polarityClassifier trainWithText:[data objectForKey:@"text"] category:@"POSITIVE"];
                positive++;
                
            } else if ([[opinion objectForKey:@"opinionPolarity"] isEqualToString:@"negative"] && negative < 403){
                
                [_polarityClassifier trainWithText:[data objectForKey:@"text"] category:@"NEGATIVE"];
                negative++;
            }
        }
    }
}

#pragma mark - Actions

-(void)categoryDetector {
    
    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"aspectTypeMain == %@", @"GENERAL"];
    
    RLMResults *identifiedAspects = [IdentifiedAspect objectsWithPredicate:predicate];
    
    for (IdentifiedAspect *identifiedAspect in identifiedAspects){
        
        NSString *string = [NSString stringWithFormat:@"%@ %@", identifiedAspect.trend, identifiedAspect.aspect];
        NSString *category = [_categoryClassifier classify:string];
        
        [defaultRealm beginWriteTransaction];
        identifiedAspect.aspectTypeSub = category;
        [defaultRealm commitWriteTransaction];
    }
    
//    NSString *string = @"but a great place to take your laptop and work to soft jazz and coffee.";
//    NSString *category = [_categoryClassifier classify:string];
//    
//    NSLog(@"%@:%@" , string, category);
}

-(NSString *)polarityDetectorWithString:(NSString *) string {
    
    NSString *polarity = [_polarityClassifier classify:string];
    
    return polarity;
    
    //    NSString *string = @"but a great place to take your laptop and work to soft jazz and coffee.";
    //    NSString *category = [_categoryClassifier classify:string];
    //
    //    NSLog(@"%@:%@" , string, category);
}

@end
