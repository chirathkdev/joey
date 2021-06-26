//
//  SearchViewController.m
//  joey
//
//  Created by Chirath Kumarasiri on 2/23/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "SearchViewController.h"
#import "UserPrefrence.h"
#import "ResultsTableViewController.h"
#import "ComponentConnector.h"
#import "LocationManager.h"
#import "LocationSearchViewController.h"
#import <QuickLook/QuickLook.h>

@interface SearchViewController () <UITextFieldDelegate, QLPreviewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet UIView *collectionView;

@property (weak, nonatomic) IBOutlet UITextField *foodTypeTextField;
@property (weak, nonatomic) IBOutlet UITextView *foodTypeListTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *cuisinesCollectionView;

@property (weak, nonatomic) IBOutlet UIImageView *locationPickerImage;
@property (weak, nonatomic) IBOutlet UIButton *locationPicker;
@property (nonatomic,strong) LocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIButton *addFoodTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *removeAllFoodTypesButton;
@property (weak, nonatomic) IBOutlet UIButton *removeLastFoodTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (weak, nonatomic) IBOutlet UISwitch *supervisedSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *unsupervisedSwitch;

@property (strong, nonatomic) NSArray *cusineList;

@property (strong, nonatomic) NSMutableArray *foodTypesArray;
@property (strong, nonatomic) NSString *selectedCuisine;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (assign, nonatomic) BOOL *searchFromRestaurant;

-(IBAction)addFoodTypeButton:(id)sender;
-(IBAction)removeAllFoodTypesButton:(id)sender;
-(IBAction)removeLastFoodTypeButton:(id)sender;
-(IBAction)searchButton:(id)sender;
-(IBAction)userManual:(id)sender;

-(IBAction)switchValueChanged:(id)sender;

-(IBAction)locationPickerButton:(id)sender;

@end

@implementation SearchViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.cuisinesCollectionView setAllowsMultipleSelection:YES];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                          action:@selector(dismissKeyboard)];
//    
//    [self.masterView addGestureRecognizer:tap];
    
//    self.masterView.backgroundColor = [UIColor colorWithRed:0.02 green:0.52 blue:0.50 alpha:0.5];
    
//    UIImage *backgroundImage = [UIImage imageNamed:@"BackgroundImage1"];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
//    
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    
//    [self.masterView addSubview:imageView];
//    [self.masterView sendSubviewToBack:imageView];
    
    NSLog(@"%@",[RLMRealmConfiguration defaultConfiguration].fileURL);
    
    _foodTypeTextField.returnKeyType = UIReturnKeyDone;
    _foodTypeTextField.delegate = self;
    
    [self.addFoodTypeButton setEnabled:NO];
    [self.removeAllFoodTypesButton setEnabled:NO];
    [self.removeLastFoodTypeButton setEnabled:NO];
    
    self.foodTypesArray = [NSMutableArray array];
    self.foodTypeListTextView.text = @"Add your desired food here";
    
    self.cusineList = @[@"American", @"Bakery", @"Bars", @"Chinese", @"Desserts", @"German" , @"Indian" , @"Japanese" , @"Korean", @"SriLankan", @"Thai"];
 
    self.selectedCuisine = @"";
    
    self.locationManager = [[LocationManager alloc] init];
    [self.locationManager retrieveCurrentLocation];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  UICollectionView Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [_cusineList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if ([_selectedIndexPath isEqual:indexPath]) {
        
        cell.layer.borderWidth= 10;
        cell.layer.borderColor= [UIColor colorWithRed:0.02 green:0.52 blue:0.50 alpha:1.0].CGColor;
        
    } else {
        
        cell.layer.borderWidth= 0;
        cell.layer.borderColor= nil;
    }
    
    NSString *cuisine = [_cusineList objectAtIndex:indexPath.row];

    UIImageView *cuisineImageView = (UIImageView *)[cell viewWithTag:100];
    cuisineImageView.image = [UIImage imageNamed:cuisine];
    
    UILabel *cuisineLabel = (UILabel *)[cell viewWithTag:101];
    cuisineLabel.text = cuisine;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    UICollectionViewCell *cell =[collectionView cellForItemAtIndexPath:indexPath];
    
    if (_selectedIndexPath == indexPath) {
        
        self.selectedIndexPath = nil;
        
        cell.layer.borderWidth= 0;
        cell.layer.borderColor= nil;
        self.selectedCuisine = @"";
        
    } else {
        
        self.selectedIndexPath = indexPath;
        
        cell.layer.borderWidth= 10;
        cell.layer.borderColor= [UIColor colorWithRed:0.02 green:0.52 blue:0.50 alpha:1.0].CGColor;
        
        UILabel *cuisineLabel = (UILabel *)[cell viewWithTag:101];
        self.selectedCuisine = cuisineLabel.text;
    }
    
    [collectionView reloadData];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    self.selectedIndexPath = nil;
    
    UICollectionViewCell *cell =[collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderWidth= 0;
    cell.layer.borderColor= nil;

    self.selectedCuisine = @"";
    
    [collectionView reloadData];
}

#pragma mark -  UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [_addFoodTypeButton setEnabled:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [_addFoodTypeButton setEnabled:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -  UIButton Methods

-(IBAction)addFoodTypeButton:(id)sender {
    
    if(_foodTypeTextField.text.length == 0) {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"That's not a Food Type"
                                     message:@"Check the text and Re Enter"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        NSString *newFoodType = [_foodTypeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _foodTypeTextField.text = @"";
        
        newFoodType = [newFoodType lowercaseString];
        
        [_foodTypesArray addObject:[self validateString:newFoodType]];
        
        self.foodTypeListTextView.text = [_foodTypesArray componentsJoinedByString:@"\n"];
        
        [self.removeAllFoodTypesButton setEnabled:YES];
        [self.removeLastFoodTypeButton setEnabled:YES];
    }
}

-(IBAction)locationPickerButton:(id)sender{
    
    LocationSearchViewController *locationSearchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationSearchViewController"];
    
    locationSearchViewController.delegate = self;
    
    [self.navigationController pushViewController:locationSearchViewController animated:YES];
}


-(IBAction)removeAllFoodTypesButton:(id)sender{
    
    [_foodTypesArray removeAllObjects];
    self.foodTypeListTextView.text = @"";
    [self.removeAllFoodTypesButton setEnabled:NO];
    [self.removeLastFoodTypeButton setEnabled:NO];
}

-(IBAction)removeLastFoodTypeButton:(id)sender{
    
    if ([_foodTypesArray count] == 1){
        
        [self.removeAllFoodTypesButton setEnabled:NO];
        [self.removeLastFoodTypeButton setEnabled:NO];
    }
    
    [_foodTypesArray removeLastObject];
    self.foodTypeListTextView.text = [_foodTypesArray componentsJoinedByString:@"\n"];
}

#pragma mark -  Switch Action Methods

-(IBAction)switchValueChanged:(id)sender{
    
    if (sender == _supervisedSwitch){
        
        if (_supervisedSwitch.isOn){
            
            [_unsupervisedSwitch setOn:NO animated:YES];
            
        } else {
            
            [_unsupervisedSwitch setOn:YES animated:YES];
        }
        
    } else {
        
        if (_unsupervisedSwitch.isOn){
            
            [_supervisedSwitch setOn:NO animated:YES];
            
        } else {
            
            [_supervisedSwitch setOn:YES animated:YES];
        }
    }
}

#pragma mark -  LocationSearchViewController Delegate Methods

-(void)sendAnnotatedDataWithLocationName:(MKPointAnnotation *)selectedPointAnnotation{
    
    [_locationPickerImage setImage:[UIImage imageNamed:@"LocationSelected"]];
    
    if (selectedPointAnnotation.title != nil && (![selectedPointAnnotation.title isEqualToString:@""])){
        
        [_locationPicker setTitle:selectedPointAnnotation.title forState:UIControlStateNormal];
        
    } else {
        
        [_locationPicker setTitle:@"Restaurant Near Location You Picked" forState:UIControlStateNormal];
    }
    
    self.locationManager.longitude = selectedPointAnnotation.coordinate.longitude;
    self.locationManager.latitude = selectedPointAnnotation.coordinate.latitude;
}

-(void)setCurrentLocation {
    
    [_locationPickerImage setImage:[UIImage imageNamed:@"LocationNotSelected"]];
    [_locationPicker setTitle:@"Restaurants Near You" forState:UIControlStateNormal];
    
    [self.locationManager retrieveCurrentLocation];
}

#pragma mark -  Support Methods

-(NSString *)validateString:(NSString *) foodType{
    
    NSString *validatedString = @"";
    
    NSArray *words = [foodType componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    for (NSString *word in  words){
        
        NSString *firstCapChar = [[word substringToIndex:1] capitalizedString];
        
        NSString *cappedString = [word stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
        
        validatedString = [validatedString stringByAppendingString:[NSString stringWithFormat:@"%@ ", cappedString]] ;
    }
    
    return [validatedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
}


#pragma mark - Search Button Method

-(IBAction)searchButton:(id)sender{
    
    if ([_foodTypesArray count ] == 0 && [_selectedCuisine isEqualToString:@""]){
        
        UIAlertController *alert = [UIAlertController
                                     alertControllerWithTitle:@"Enter Your Preference"
                                     message:@"Enter Something"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        RLMRealm *defaultRealm = [RLMRealm defaultRealm];
        
        if (defaultRealm){
            
            RLMRealm *defaultRealm = [RLMRealm defaultRealm];
            [defaultRealm beginWriteTransaction];
            [defaultRealm deleteAllObjects];
            [defaultRealm commitWriteTransaction];
            
        }
        
        UserPrefrence *userPreference = [[UserPrefrence alloc] init];
        userPreference.foodType = [_foodTypesArray componentsJoinedByString:@","];
        userPreference.cuisine = _selectedCuisine;
        userPreference.budgetRange = 0;
        userPreference.latitude = _locationManager.latitude;
        userPreference.longitude = _locationManager.longitude;
        userPreference.supervised = [_supervisedSwitch isOn];
        userPreference.unsupervised = [_unsupervisedSwitch isOn];
        
        [defaultRealm beginWriteTransaction];
        [defaultRealm addObject:userPreference];
        [defaultRealm commitWriteTransaction];
        
        UIViewController *loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadingViewController"];
        
        loadingViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [self presentViewController:loadingViewController animated:YES completion:nil];
        
        ComponentConnector *connector = [[ComponentConnector alloc] init];
        [connector initializeComponentConnectorWithLoadingView:(LoadingViewController *) loadingViewController completion:^(BOOL success) {
            
            if (success) {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
                
                UITableViewController *resultsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultsTableViewController"];
                [self.navigationController pushViewController:resultsTableViewController animated:YES];
            }
        }];
    }
}

-(IBAction)userManual:(id)sender{
    
    QLPreviewController *preview = [[QLPreviewController alloc] init];
    preview.dataSource = self;
    [self presentViewController:preview animated:YES completion:nil];
}

-(NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller {
    
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {

    return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"UserManual" ofType:@"pdf"]];
}

//-(void)dismissKeyboard {
//    [_foodTypeTextField resignFirstResponder];
//}

@end
