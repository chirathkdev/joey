//
//  UserPreferenceHandler.h
//  joey
//
//  Created by Chirath Kumarasiri on 2/8/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "UserPrefrence.h"

@interface UserPreferenceHandler : NSObject

//@property (nonatomic,copy) NSString *userCuisine;
//@property (nonatomic,copy) NSArray *userFoodTypes;
//
//+ (UserPreferenceHandler *)sharedInstance;

@property (strong, nonatomic) UserPrefrence *userPreference;

@property (strong, nonatomic) NSArray *userDishList;
@property (strong, nonatomic) NSArray *cuisineDishList;
@property (strong, nonatomic) NSArray *fullDishList;

@end
