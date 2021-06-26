//
//  LocationSearchViewController.m
//  joey
//
//  Created by Chirath Kumarasiri on 3/23/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "LocationSearchViewController.h"
#import "LocationSearchTableViewController.h"

@interface LocationSearchViewController ()

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) MKPlacemark *selectedPlaceMark;
@property (nonatomic, strong) MKPointAnnotation *selectedPointAnnotation;

@property (assign, nonatomic) BOOL firstTimeUserCenter;


@end

@implementation LocationSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.firstTimeUserCenter = YES;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];
    
    MKUserTrackingBarButtonItem *buttonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:_mapView];
    self.navigationItem.rightBarButtonItem = buttonItem;
    
    LocationSearchTableViewController *locationSearchTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationSearchTableViewController"];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:locationSearchTableViewController];
    self.searchController.searchResultsUpdater = locationSearchTableViewController;

    UISearchBar *searchBar = _searchController.searchBar;
    [searchBar sizeToFit];
    searchBar.placeholder = @"Search for places";
    self.navigationItem.titleView = _searchController.searchBar;
    
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;

    locationSearchTableViewController.mapView = _mapView;

    locationSearchTableViewController.handleMapSearchDelegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  MKMapView Delegate Methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (_firstTimeUserCenter){
        
        MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
        MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        
        self.mapView.userLocation.title = @"You are here";
        
        self.mapView.userTrackingMode = MKUserTrackingModeNone;
        
        self.firstTimeUserCenter = NO;
        
        //    // Add an annotation
        //    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        //    point.coordinate = userLocation.coordinate;
        //    point.title = @"Where am I?";
        //    point.subtitle = @"I'm here!!!";
        //    
        //    [self.mapView addAnnotation:point];
    }
}

- (void)dropPinZoomIn:(MKPlacemark *)placemark {
    
    // cache the pin
    self.selectedPlaceMark = placemark;
    // clear existing pins
    [_mapView removeAnnotations:(_mapView.annotations)];
    
    self.selectedPointAnnotation = [MKPointAnnotation new];
    self.selectedPointAnnotation.coordinate = placemark.coordinate;
    self.selectedPointAnnotation.title = placemark.name;
    self.selectedPointAnnotation.subtitle = [NSString stringWithFormat:@"%@ %@",
                           (placemark.locality == nil ? @"" : placemark.locality),
                           (placemark.administrativeArea == nil ? @"" : placemark.administrativeArea)
                           ];
    [_mapView addAnnotation:self.selectedPointAnnotation];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(placemark.coordinate, span);
    [_mapView setRegion:region animated:true];
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *reuseId = @"pin";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pinView.enabled = YES;
        pinView.canShowCallout = YES;
        pinView.tintColor = [UIColor orangeColor];
    } else {
        pinView.annotation = annotation;
    }
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [button setBackgroundImage:[UIImage imageNamed:@"LocationNotSelected"]
                          forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
        pinView.leftCalloutAccessoryView = button;
        
    } else {
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [button setBackgroundImage:[UIImage imageNamed:@"LocationSelected"]
                          forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectVenue) forControlEvents:UIControlEventTouchUpInside];
        pinView.leftCalloutAccessoryView = button;
        
    }
    
    return pinView;
}

- (void)selectVenue {

    [self.delegate sendAnnotatedDataWithLocationName:_selectedPointAnnotation];
    
    [self.navigationController popViewControllerAnimated:YES];
    //    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:_selectedPin];
    //    [mapItem openInMapsWithLaunchOptions:(@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving})];
}

- (void)selectCurrentLocation {
    
    [self.delegate setCurrentLocation];
    
    [self.navigationController popViewControllerAnimated:YES];
    //    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:_selectedPin];
    //    [mapItem openInMapsWithLaunchOptions:(@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving})];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    // clear existing pins
    [_mapView removeAnnotations:(_mapView.annotations)];
  
    self.selectedPointAnnotation = [MKPointAnnotation new];
    self.selectedPointAnnotation.coordinate = touchMapCoordinate;
    self.selectedPointAnnotation.title = @"Custom Location";
    [_mapView addAnnotation:self.selectedPointAnnotation];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(touchMapCoordinate, span);
    [_mapView setRegion:region animated:true];
}

@end
