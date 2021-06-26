//
//  LocationManager.h
//  joey
//
//  Created by Chirath Kumarasiri on 3/6/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationManager : NSObject

@property (assign) double latitude;
@property (assign) double longitude;

-(void)retrieveCurrentLocation;

@end
