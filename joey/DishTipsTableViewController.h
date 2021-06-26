//
//  DishTipsTableViewController.h
//  joey
//
//  Created by Chirath Kumarasiri on 3/5/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

@interface DishTipsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *userAspectTips;
@property (strong, nonatomic) NSArray *cuisineAspectTips;

@property (strong, nonatomic) NSArray *dishAspects;

@end
