//
//  UserPrefrence.h
//  joey
//
//  Created by Chirath Kumarasiri on 2/25/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Realm/Realm.h>

@interface UserPrefrence : RLMObject

@property NSString *foodType;
@property NSString *cuisine;

@property NSInteger budgetRange;

@property double latitude;
@property double longitude;

@property BOOL supervised;
@property BOOL unsupervised;

@end
