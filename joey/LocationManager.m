//
//  LocationManager.m
//  joey
//
//  Created by Chirath Kumarasiri on 3/6/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationManager() <CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *coreLocationManager;

@end

@implementation LocationManager

-(instancetype)init {
    
    if (self = [super init]) {
        
        self.coreLocationManager = [CLLocationManager new];
        
        self.latitude = 6.8652715;
        self.longitude = 79.8598505;
        
        [_coreLocationManager requestWhenInUseAuthorization];
    }
    return  self;
}

-(void)retrieveCurrentLocation {
    
    self.coreLocationManager = [[CLLocationManager alloc] init];
    
    self.coreLocationManager.delegate = self;
    self.coreLocationManager.distanceFilter = kCLDistanceFilterNone;
    self.coreLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [_coreLocationManager startUpdatingLocation];
        
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ) {

        [_coreLocationManager requestWhenInUseAuthorization];
        
    } else {

//        NSString *title = @"Location services are off";
//        NSString *message = @"Turn on Location Services in Settings to determine your current location.";
       
////        UIAlertController *alert = [UIAlertController alalertControllerWithTitle:title
////                                                            message:message
////                                                           delegate:self
////                                                  cancelButtonTitle:@"Cancel"
////                                                  otherButtonTitles:@"Settings", nil];
////
////
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError: %@", error);
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    CLLocation *currentLocation = [locations lastObject];
    
    NSLog(@"Location: %@", currentLocation);
    
    if (currentLocation != nil) {
        
        self.longitude = currentLocation.coordinate.longitude;
        self.latitude = currentLocation.coordinate.latitude;
        
    }
    
    _coreLocationManager.delegate = nil;
    [_coreLocationManager stopUpdatingLocation];
}
@end
