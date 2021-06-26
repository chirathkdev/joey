//
//  DishTipsTableViewController.m
//  joey
//
//  Created by Chirath Kumarasiri on 3/5/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "DishTipsTableViewController.h"

@interface DishTipsTableViewController ()

@end

@implementation DishTipsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_userAspectTips && _cuisineAspectTips){
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_userAspectTips && _cuisineAspectTips){
        
        if (section == 0){
            return [_userAspectTips count];
        } else {
            return [_cuisineAspectTips count];
        }
        
    } else if (_userAspectTips){
        
        return [_userAspectTips count];
        
    } else {
        
        return [_cuisineAspectTips count];
    }
}

#pragma mark - UITableView Delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    
    if (tableView.numberOfSections == 2){
        
        if (section == 0) {
            
            sectionName = @"Tips with User Dishes";
            
        } else {
            
            sectionName = @"Tips with Cuisine Dishes";
        }
        
    } else {
        
        if (_userAspectTips){
            
            sectionName = @"Tips with User Dishes";

        } else {
            
            sectionName = @"Tips with Cuisine Dishes";
        }
    }
    
    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    
    if (tableView.numberOfSections == 2){
        
        if (indexPath.section == 0){
            
            NSString *string = [_userAspectTips objectAtIndex:indexPath.row];
            
            titleLabel.attributedText = [self checkForDishNames:string];
            
        } else {
            
            NSString *string = [_cuisineAspectTips objectAtIndex:indexPath.row];
            titleLabel.attributedText = [self checkForDishNames:string];
        }
        
    } else {
        
        if (_userAspectTips){
            
            NSString *string = [_userAspectTips objectAtIndex:indexPath.row];
            titleLabel.attributedText = [self checkForDishNames:string];
            
        } else {
            
            NSString *string = [_cuisineAspectTips objectAtIndex:indexPath.row];
            titleLabel.attributedText = [self checkForDishNames:string];
        }
    }

    return cell;
}

-(NSMutableAttributedString *)checkForDishNames:(NSString *) string{
    
    NSMutableAttributedString *stringWithColor = [[NSMutableAttributedString alloc] initWithString:string];
    
    [stringWithColor addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.02 green:0.52 blue:0.50 alpha:1.0] range:NSMakeRange(0, stringWithColor.length)];
    
    for (NSString *dish in _dishAspects){
        
        NSRange searchResult = [string rangeOfString:dish options:NSLiteralSearch];
        
        if (searchResult.location != NSNotFound) {
            
            NSString *dishName = [dish stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            string = [string stringByReplacingCharactersInRange:searchResult withString:dishName];
            
            [stringWithColor addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1.00 green:0.27 blue:0.24 alpha:1.0] range:searchResult];
        }
    }
    
    return stringWithColor;
}
@end
