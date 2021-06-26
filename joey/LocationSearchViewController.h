//
//  LocationSearchViewController.h
//  joey
//
//  Created by Chirath Kumarasiri on 3/23/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol HandleMapSearch <NSObject>

- (void)dropPinZoomIn:(MKPlacemark *)placemark;

@end

@protocol senddataProtocol <NSObject>

-(void)sendAnnotatedDataWithLocationName:(MKPointAnnotation *)selectedPointAnnotation;
-(void)setCurrentLocation;

@end


@interface LocationSearchViewController : UIViewController <HandleMapSearch, MKMapViewDelegate>

@property(nonatomic,assign)id delegate;

@end
