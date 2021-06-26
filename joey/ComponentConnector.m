//
//  ComponentConnector.m
//  joey
//
//  Created by Chirath Kumarasiri on 2/26/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "ComponentConnector.h"
#import "FoursquareHandler.h"
#import "TipProcessor.h"
#import "SentimentAllocator.h"
#import "UserPreferenceHandler.h"
#import "TipClassifier.h"

@interface ComponentConnector ()

@property (nonatomic,strong) FoursquareHandler *foursquareHandler;
@property (nonatomic,strong) UserPreferenceHandler *userPreferenceHandler;

@end

@implementation ComponentConnector

-(void) initializeComponentConnectorWithLoadingView:(LoadingViewController *) loadingViewController completion:(void(^)(BOOL success)) completionBlock {
    
    self.foursquareHandler = [[FoursquareHandler alloc] init];
    self.userPreferenceHandler = [[UserPreferenceHandler alloc] init];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_t group1 = dispatch_group_create();
    dispatch_group_t group2 = dispatch_group_create();
    dispatch_group_t group3 = dispatch_group_create();
    dispatch_group_t group4 = dispatch_group_create();
    
    dispatch_group_enter(group1);
    
    [loadingViewController loadingVenues];
    
    [self requestVenues:^(BOOL success){
        
        if (success){
            dispatch_group_leave(group1);
        }
    }];
    
    dispatch_group_enter(group2);
    
    // Make the second task wait until group1 has completed before running
    dispatch_group_notify(group1, queue, ^{
        
        [self requestTips:^(BOOL success){
            
            if (success) {
                dispatch_group_leave(group2);
            }
        }];
    });
    
    dispatch_group_enter(group3);
    
    dispatch_group_notify(group2, queue, ^{
        
        [self processReviews:^(BOOL success){
            
            if (success) {
                dispatch_group_leave(group3);
            }
        }];
    });
    
    dispatch_group_enter(group4);
    
    dispatch_group_notify(group3, queue, ^{
        
        [self calculateSentiment:^(BOOL success){
            
            if (success) {
                dispatch_group_leave(group4);
                completionBlock (YES);
            }
        }];
    });
    
    dispatch_group_notify(group1, dispatch_get_main_queue(), ^{
        
        [loadingViewController dismissLoading];
        [loadingViewController loadingTips];
    });
    
    dispatch_group_notify(group2, dispatch_get_main_queue(), ^{
        
        [loadingViewController dismissLoading];
        [loadingViewController loadingProcessing];
    });
    
    dispatch_group_notify(group3, dispatch_get_main_queue(), ^{
        
        [loadingViewController dismissLoading];
        [loadingViewController loadingSenitments];
        
        TipClassifier *classifier = [[TipClassifier alloc] init];
        
        [classifier trainCategoryClassifier];
        [classifier categoryDetector];
    });
    
    dispatch_group_notify(group4, dispatch_get_main_queue(), ^{
        
        [loadingViewController dismissLoading];
    });

}

#pragma mark - Foursquare Handler Methods

-(void) requestVenues:(void(^)(BOOL success)) completionBlock{
    
    double latitude = _userPreferenceHandler.userPreference.latitude;
    double longitude = _userPreferenceHandler.userPreference.longitude;
    
    NSString *query = @"";
    
    if (![_userPreferenceHandler.userPreference.cuisine isEqualToString:@""]){
        
        query = _userPreferenceHandler.userPreference.cuisine;
        
    } else {
        
        query = _userPreferenceHandler.userPreference.foodType;
        query = [query stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    [_foursquareHandler retrieveVenuesNearLatitude:latitude andLongitude:longitude andQuery:query onCompletion:^(BOOL success, NSError *error) {
        
        if (success){
            
            NSLog(@"Venus Gathered");
            completionBlock (YES);
            
        } else {
            
            NSLog(@"ERROR - Venus Gathered");
            completionBlock (NO);
        }
    }];
}

-(void) requestTips:(void(^)(BOOL success)) completionBlock{
    
    [_foursquareHandler retrieveTipsForVenuesOnCompletion:^(BOOL success, NSError *error) {

        if (success){
            
            NSLog(@"Tips Gathered");
            completionBlock (YES);
            
        } else {
            
            NSLog(@"ERROR - Tips Gathered");
            completionBlock (NO);
        }
    }];
    
}

#pragma mark - Tip Processor Handler Methods

-(void) processReviews:(void(^)(BOOL success)) completionBlock{
    
    TipProcessor *processor = [[TipProcessor alloc] init];
    [processor initializeProcessorOnCompletion:^(BOOL success) {
        
        if (success){
            
            NSLog(@"Processing Complete");
            completionBlock (YES);
        } else {
            
            NSLog(@"ERROR - Processing Complete");
            completionBlock (NO);
        }
        
    }];
}

#pragma mark - Sentiment Allocator Handler Methods

-(void) calculateSentiment:(void(^)(BOOL success)) completionBlock {
    
    SentimentAllocator *allocator = [[SentimentAllocator alloc] init];
    [allocator initializeSentimentAllocatorOnCompletion:^(BOOL success) {
        
        if (success){
            
            NSLog(@"Sentiment Complete");
            completionBlock (YES);
        } else {
            
            NSLog(@"ERROR - Sentiment Complete");
            completionBlock (NO);
        }
    }];
}

@end
