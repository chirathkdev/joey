//
//  UserPreferenceHandler.m
//  joey
//
//  Created by Chirath Kumarasiri on 2/8/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "UserPreferenceHandler.h"

@interface UserPreferenceHandler ()

//@property (strong, nonatomic) NSString *userCuisineInput;
//@property (strong, nonatomic) NSArray *userFoodTypesInputArray;
//
//@property (strong, nonatomic) NSMutableArray *dishListArray;
//
//@property (strong, nonatomic) NSMutableArray *finalFoodTypesArray;

@end

@implementation UserPreferenceHandler

- (instancetype)init{
    
    self = [super init];
    if (self) {
        
        self.userPreference = [[UserPrefrence allObjects] firstObject];
        
        [self initializeUserDishLists];
        [self initializeFullDishLists];
    }
    return self;
}

-(void) initializeUserDishLists{
    
    if (_userPreference.foodType){
        
        self.userDishList = [_userPreference.foodType componentsSeparatedByString:@","];
        
    } else {
        
        self.userDishList = nil;
    }
    
    if (_userPreference.cuisine){
        
        self.cuisineDishList = [self loadCuisineDishList:_userPreference.cuisine];
        
    } else {
        
        self.cuisineDishList = nil;
    }
}

-(void) initializeFullDishLists{
    
    NSMutableArray *customDishList = [NSMutableArray array];

    if (_userDishList && _cuisineDishList){
        
        [customDishList addObjectsFromArray:_cuisineDishList];

        for (NSString *userDish in _userDishList) {
            
            if(![_cuisineDishList containsObject:userDish]){
                
                [customDishList addObject:userDish];
            }
        }
        
    } else if (_userDishList) {
        
         [customDishList addObjectsFromArray:_userDishList];
    }
    
    self.fullDishList = customDishList;
}

-(NSMutableArray *)  loadCuisineDishList:(NSString *) cuisine {
    
    NSMutableArray *dishList = [NSMutableArray array];
    
    if (![cuisine isEqualToString:@""]){
    
        NSString *fileText = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:cuisine ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
        
        dishList = (NSMutableArray *)[fileText componentsSeparatedByString:@"\r\n"];
        [dishList removeLastObject];
        
    }
    
    return dishList;
}

//+ (UserPreferenceHandler *)sharedInstance {
//    
//    static UserPreferenceHandler *userPreferenceHandler = nil;
//
//    static dispatch_once_t oncePredicate;
//    
//    dispatch_once(&oncePredicate, ^{
//        
//        userPreferenceHandler = [[UserPreferenceHandler alloc] init];
//        
//        UserPrefrence *userPreference =  [[UserPrefrence allObjects] firstObject];
//
//        userPreferenceHandler.userCuisineInput = userPreference.cuisine;
//        
//        if (_userCuisineInput){
//            
//            userPreferenceHandler.dishListArray = [self loadCuisineDishList];
//            
//        } else {
//            
//            userPreferenceHandler.dishListArray = nil;
//        }
//        
//        if (userPreference.foodType) {
//            
//            userPreferenceHandler.userFoodTypesInputArray = [userPreference.foodType componentsSeparatedByString:@","];
//        } else {
//            
//            userPreferenceHandler.userFoodTypesInputArray = nil;
//            
//        }
//
//        
//        
//    });
//    
//    return userPreferenceHandler;
//}

//+ (instancetype)sharedInstance
//{
//    static UnttapdFlowController *sharedInstance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedInstance = [[UnttapdFlowController alloc] init];
//        // Do any other initialisation stuff here
//    });
//    return sharedInstance;
//}

@end
