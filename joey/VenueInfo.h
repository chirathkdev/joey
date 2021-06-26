//
//  VenueInfo.h
//  joey
//
//  Created by Chirath Kumarasiri on 2/2/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Realm/Realm.h>

@interface VenueInfo : RLMObject

@property NSString *name;
@property NSString *foursquareId;
@property NSString *latitude;
@property NSString *longitude;

@property NSString *address;
@property NSString *category;

@property NSNumber<RLMDouble> *distance;

@property NSString *imageURL;

@end
