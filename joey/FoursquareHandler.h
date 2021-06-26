//
//  FoursquareHandler.h
//  joey
//
//  Created by Chirath Kumarasiri on 1/23/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface FoursquareHandler : NSObject

@property (nonatomic,assign) BOOL isRetrievingNearByLocations;

-(void)retrieveVenuesNearLatitude:(double)latitude andLongitude:(double)longitude andQuery:(NSString *) query onCompletion:(void(^)(BOOL success, NSError *error)) completionBlock;


-(void)retrieveTipsForVenuesOnCompletion:(void(^)(BOOL success, NSError *error)) completionBlock;

@end
