//
//  LocationSearchTableViewController.h
//  joey
//
//  Created by Chirath Kumarasiri on 3/23/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LocationSearchViewController.h"

@interface LocationSearchTableViewController : UITableViewController <UISearchResultsUpdating>

@property (nonatomic, strong) MKMapView *mapView;
@property id <HandleMapSearch>handleMapSearchDelegate;

@end
