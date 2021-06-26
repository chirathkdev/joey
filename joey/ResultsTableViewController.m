//
//  ResultsTableViewController.m
//  joey
//
//  Created by Chirath Kumarasiri on 2/25/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "ResultsTableViewController.h"
#import "Venue.h"
#import "RestaurantAnalysisViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ResultsTableViewController ()

@property (strong, nonatomic) RLMResults <Venue *> *sortedVenues;

@end

@implementation ResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.sortedVenues = [[Venue allObjects] sortedResultsUsingKeyPath:@"venueSentiment" ascending:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_sortedVenues count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Venue *venue = [_sortedVenues objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
//    if (indexPath.row < 3){
//        
//        cell.backgroundColor = [UIColor colorWithRed:0.02 green:0.52 blue:0.50 alpha:1.0];
//    }
    
    UIImageView *restaurantImage = (UIImageView *)[cell viewWithTag:100];
    
    if (venue.venueInfo.imageURL) {
        
        [restaurantImage sd_setImageWithURL:[NSURL URLWithString:venue.venueInfo.imageURL] placeholderImage:nil completed:nil];
        
    } else {
        
        restaurantImage.image = [UIImage imageNamed:@"RestaurantImage"];
    }
    
//    if (venue.venueInfo.imageURL) {
//        
//        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:venue.venueInfo.imageURL]]];
//        restaurantImage.image = image;
//        
//    } else {
//    
//        restaurantImage.image = [UIImage imageNamed:@"RestaurantImage"];
//    }
//    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    titleLabel.text = venue.venueInfo.name;
    
    UILabel *distanceLabel = (UILabel *)[cell viewWithTag:102];
    
    if ([venue.venueInfo.distance integerValue] > 1000){
        
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setPositiveFormat:@"0.##"];
        
        float number = ([venue.venueInfo.distance floatValue] / 1000.0f);
        
        distanceLabel.text = [NSString stringWithFormat:@"%@ km", [fmt stringFromNumber:[NSNumber numberWithFloat:number]]];
        
    } else {
        
        distanceLabel.text = [NSString stringWithFormat:@"%@ m", [venue.venueInfo.distance stringValue]];
    }

    UIImageView *pointsImage = (UIImageView *)[cell viewWithTag:103];
    pointsImage.image = [UIImage imageNamed:@"PointsImage"];
    
    UILabel *pointsLabel = (UILabel *)[cell viewWithTag:104];
    pointsLabel.text = [NSString stringWithFormat: @"%ld", (long)venue.venueSentiment];
    
    UILabel *tipsLabel = (UILabel *)[cell viewWithTag:105];
    tipsLabel.text = [NSString stringWithFormat: @"From %ld tips", (long)venue.tips.count];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Venue *selectedVenue = [_sortedVenues objectAtIndex:indexPath.row];
    
    RestaurantAnalysisViewController *restaurantAnalysisViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RestaurantAnalysisViewController"];
    [self.navigationController pushViewController:restaurantAnalysisViewController animated:YES];
    
    restaurantAnalysisViewController.selectedVenue = selectedVenue;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
