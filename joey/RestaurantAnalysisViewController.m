//
//  RestaurantAnalysisViewController.m
//  joey
//
//  Created by Chirath Kumarasiri on 3/2/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "RestaurantAnalysisViewController.h"
#import "PNChart.h"
#import "DishTipsTableViewController.h"

@interface RestaurantAnalysisViewController ()

@property (weak, nonatomic) IBOutlet UILabel *restaurantName;
@property (weak, nonatomic) IBOutlet UILabel *restaurantAddress;

@property (weak, nonatomic) IBOutlet UITextView *tagCloudTextView;

@property (weak, nonatomic) IBOutlet UILabel *topTip;
@property (weak, nonatomic) IBOutlet UILabel *worstTip;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *dishAspectsButton;
@property (weak, nonatomic) IBOutlet UIButton *generalAspectsButton;

-(IBAction)dishAspectsButton:(id)sender;
-(IBAction)generalAspectsButton:(id)sender;

@end

@implementation RestaurantAnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.restaurantName.text = _selectedVenue.venueInfo.name;
    self.restaurantAddress.text = _selectedVenue.venueInfo.address;
    
    self.topTip.text = @"";
    self.worstTip.text = @"";
    
    [[_dishAspectsButton layer] setBorderWidth:2.0f];
    [[_dishAspectsButton layer] setBorderColor:[UIColor colorWithRed:0.02 green:0.52 blue:0.50 alpha:1.0].CGColor];
    
    [[_generalAspectsButton layer] setBorderWidth:2.0f];
    [[_generalAspectsButton layer] setBorderColor:[UIColor colorWithRed:0.02 green:0.52 blue:0.50 alpha:1.0].CGColor];
    
    [self createTagCloud];
    
    [self createTopAndWorstTip];
    
//    [self createUserDishListChart];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Create Tag Cloud

-(void)createTagCloud{
    
    NSMutableArray *tagCloudArray = [NSMutableArray array];
    NSMutableArray *existingTagNames = [NSMutableArray array];
    
    for (IdentifiedAspect *identifiedAspect in _selectedVenue.identifiedAspects){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"aspect == %@", identifiedAspect.aspect];
        
        RLMResults *aspectsForPredicate = [_selectedVenue.identifiedAspects objectsWithPredicate:predicate];
        
        NSInteger tagCount = [aspectsForPredicate count];
        
        if (![existingTagNames containsObject:identifiedAspect.aspect]){
            
            [existingTagNames addObject:identifiedAspect.aspect];
        
            [tagCloudArray addObject:@{@"tagname":identifiedAspect.aspect,@"tagcount":[NSNumber numberWithInt:(int)tagCount]}];
        }
    }
 
    NSSortDescriptor *tagCountDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tagcount"  ascending:NO];
    
    NSArray *sortedTagCloud = [tagCloudArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:tagCountDescriptor,nil]];
    
    NSArray *sortedTopTenTagCloud = [NSArray array];
    
    if ([sortedTagCloud count] < 10){
        
        sortedTopTenTagCloud = [NSArray arrayWithArray:sortedTagCloud];
        
    } else {
        
        sortedTopTenTagCloud = [sortedTagCloud subarrayWithRange:NSMakeRange(0, 10)];
    }

    NSMutableArray *finalTagCloudArray = [NSMutableArray array];
    
    NSMutableAttributedString *finalTagCloudString = [[NSMutableAttributedString alloc] init];
    float fontSize = 10.0f;
    NSInteger index = 0;
    
    for (NSDictionary *tag in sortedTopTenTagCloud){
        
        switch (index) {
            case 0:
                fontSize = 42.0f;
                break;
            case 1:
                fontSize = 40.0f;
                break;
            case 2:
                fontSize = 32.0f;
                break;
            case 3:
                fontSize = 32.0f;
                break;
            case 4:
                fontSize = 24.0f;
                break;
            case 5:
                fontSize = 24.0f;
                break;
            case 6:
                fontSize = 18.0f;
                break;
            case 7:
                fontSize = 18.0f;
                break;
                
            default:
                fontSize = 14.0f;
                break;
        }
        index++;
        
        [finalTagCloudArray addObject:@{@"tagname":[tag objectForKey:@"tagname"], @"fontsize":[NSNumber numberWithFloat:fontSize]}];   
    }
    
    NSSortDescriptor *tagNamedescriptor = [[NSSortDescriptor alloc] initWithKey:@"tagname"  ascending:YES];
    
    NSArray *sortedFinalTagCloudArray = [finalTagCloudArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:tagNamedescriptor,nil]];
    
    for(NSDictionary *tag in sortedFinalTagCloudArray){
        
        float tagFontSize = [[tag objectForKey:@"fontsize"] floatValue];
        
        NSDictionary *attributes = @{
                                     NSForegroundColorAttributeName : [UIColor whiteColor],
                                     NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:tagFontSize]
                                     };
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  ",[tag objectForKey:@"tagname"]] attributes:attributes];

        [finalTagCloudString appendAttributedString:attrString];
    }
    
    [[self.tagCloudTextView textStorage] appendAttributedString:finalTagCloudString];
}

#pragma mark - Top And Worst Tip

-(void) createTopAndWorstTip{
    
    NSString *topTip = @"";
    NSString *worstTip = @"";
    
    NSInteger maxSentiment = 0;
    NSInteger minSentiment = 0;
    
    
    for (Tip *tip in _selectedVenue.tips){
        
        if (tip.tipSentiment > maxSentiment){
            
            topTip = tip.tipText;
            maxSentiment = tip.tipSentiment;
            
        } else if (tip.tipSentiment < minSentiment) {
            
            worstTip = tip.tipText;
            minSentiment = tip.tipSentiment;
        }
    }
    
    if (maxSentiment > 0) {
        
        self.topTip.text = topTip;
    }
    
    if (minSentiment < 0){
        
        self.worstTip.text = worstTip;
    }
}

#pragma mark - Dish Aspects Button

-(IBAction)dishAspectsButton:(id)sender{
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"aspectTypeMain == %@", @"USER"];
    
    RLMResults *userAspects = [_selectedVenue.identifiedAspects objectsWithPredicate:userPredicate];
    
    NSPredicate *cuisinePredicate = [NSPredicate predicateWithFormat:@"aspectTypeMain == %@", @"CUISINE"];
    
    RLMResults *cuisineAspects = [_selectedVenue.identifiedAspects objectsWithPredicate:cuisinePredicate];
    
    if (([userAspects count] == 0) && ([cuisineAspects count] == 0)) {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Oops..."
                                     message:@"joey could not find your dishes in this venue's tips"
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
        
        NSMutableArray *dishAspectsArray = [NSMutableArray array];
        NSMutableArray *userTipArray = [NSMutableArray array];
        
        if ([userAspects count] != 0){
            
            for (IdentifiedAspect *userAspect in userAspects){
                
                NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"tipId == %@" , userAspect.tipId];
                
                RLMResults *tips = [_selectedVenue.tips objectsWithPredicate:userPredicate];
                
                Tip *tip = [tips firstObject];
                
                if (![userTipArray containsObject:tip.tipWithDishNameText]){
                    [userTipArray addObject:tip.tipWithDishNameText];
                }
                
                if (![dishAspectsArray containsObject:userAspect.aspect]){
                    [dishAspectsArray addObject:userAspect.aspect];
                }
            }
            
        } else {
            
            userTipArray = nil;
        }
        
        NSMutableArray *cuisineTipArray = [NSMutableArray array];
        
        if ([cuisineAspects count] != 0){
            
            for (IdentifiedAspect *cuisineAspect in cuisineAspects){
                
                NSPredicate *cuisinePredicate = [NSPredicate predicateWithFormat:@"tipId == %@" , cuisineAspect.tipId];
                
                RLMResults *tips = [_selectedVenue.tips objectsWithPredicate:cuisinePredicate];
                
                Tip *tip = [tips firstObject];
                
                if (![cuisineTipArray containsObject:tip.tipWithDishNameText]){
                    [cuisineTipArray addObject:tip.tipWithDishNameText];
                }
                
                if (![dishAspectsArray containsObject:cuisineAspect.aspect]){
                    [dishAspectsArray addObject:cuisineAspect.aspect];
                }
            }
            
        } else {
            
            cuisineTipArray = nil;
        }
        
        DishTipsTableViewController *dishTipsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DishTipsTableViewController"];
        
        dishTipsTableViewController.userAspectTips = userTipArray;
        dishTipsTableViewController.cuisineAspectTips = cuisineTipArray;
        
        dishTipsTableViewController.dishAspects = dishAspectsArray;
        
        [self.navigationController pushViewController:dishTipsTableViewController animated:YES];
        
    }
}

#pragma mark - General Aspects Button

-(IBAction)generalAspectsButton:(id)sender{
    
    float ambienceSentiment = 0;
    float ambienceCount = 0;
    
    float foodSentiment = 0;
    float foodCount = 0;
    
    float restaurantSentiment = 0;
    float restaurantCount = 0;
    
    float serviceSentiment = 0;
    float serviceCount = 0;
    
    for (IdentifiedAspect *aspect in _selectedVenue.identifiedAspects){
        
        if ([aspect.aspectTypeSub isEqualToString:@"AMBIENCE"]){
            
            ambienceSentiment += aspect.aspectWeight;
            ambienceCount++;
            
        } else if ([aspect.aspectTypeSub isEqualToString:@"FOOD"]){
            
            foodSentiment += aspect.aspectWeight;
            foodCount++;
            
        } else if ([aspect.aspectTypeSub isEqualToString:@"RESTAURANT"]){
            
            restaurantSentiment += aspect.aspectWeight;
            restaurantCount++;
            
        } else if ([aspect.aspectTypeSub isEqualToString:@"SERVICE"]) {
            
            serviceSentiment += aspect.aspectWeight;
            serviceCount++;
        }
    }
    
    float totalCategoryCount = ambienceCount + foodCount + restaurantCount + serviceCount;
    
    UIViewController *chartViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChartViewController"];
    
    
    //Creating the bar chart
    PNBarChart *barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 90.0, SCREEN_WIDTH, 200.0)];
    barChart.isGradientShow = NO;
    barChart.chartMarginTop = 10.0;
    
    barChart.strokeColor = [UIColor colorWithRed:0.02 green:0.52 blue:0.50 alpha:1.0];
    barChart.labelTextColor = [UIColor blackColor];
    barChart.showChartBorder = YES;
    [barChart setXLabels:@[@"AMBIENCE",@"FOOD",@"RESTAURANT",@"SERVICE"]];
    
    [barChart setYValues:@[[NSNumber numberWithInteger:ambienceSentiment],  [NSNumber numberWithInteger:foodSentiment], [NSNumber numberWithInteger:restaurantSentiment], [NSNumber numberWithInteger:serviceSentiment]]];
    
    [barChart strokeChart];
    
    [chartViewController.view addSubview:barChart];
    
    //Creating the pie chart
    NSArray *items = @[[PNPieChartDataItem dataItemWithValue:((ambienceCount/totalCategoryCount)*100) color:PNGreen description:@"AMBIENCE"],
                       
                       [PNPieChartDataItem dataItemWithValue:((foodCount/totalCategoryCount)*100) color:PNDeepGrey description:@"FOOD"],
                       
                       [PNPieChartDataItem dataItemWithValue:((restaurantCount/totalCategoryCount)*100) color:[UIColor colorWithRed:0.02 green:0.52 blue:0.50 alpha:1.0] description:@"RESTAURANT"],
                       
                       [PNPieChartDataItem dataItemWithValue:((serviceCount/totalCategoryCount)*100) color:PNBlack description:@"SERVICE"]
                       ];
    

    PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(60.0, 400.0, 220.0, 150.0) items:items];
    pieChart.descriptionTextColor = [UIColor whiteColor];
    pieChart.descriptionTextFont  = [UIFont fontWithName:@"Helvetica-Bold" size:10.0];
    [pieChart strokeChart];
    
    [chartViewController.view addSubview:pieChart];
    
    [self.navigationController pushViewController:chartViewController animated:YES];
}

@end
