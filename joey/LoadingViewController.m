//
//  LoadingViewController.m
//  joey
//
//  Created by Chirath Kumarasiri on 2/26/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import "LoadingViewController.h"
#import "WSProgressHUD.h"

@interface LoadingViewController () <CAAnimationDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) WSProgressHUD *hud;

@end

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *image1 = [UIImage imageNamed:@"BackgroundImage1"];
    UIImage *image2 = [UIImage imageNamed:@"BackgroundImage2"];
    UIImage *image3 = [UIImage imageNamed:@"BackgroundImage3"];
    UIImage *image4 = [UIImage imageNamed:@"BackgroundImage4"];
    
    NSArray *images = [[NSArray alloc] initWithObjects:image1, image2, image3, image4, nil];
//
//    [self animateImages:images];
    
    self.hud = [[WSProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hud];
    
//    [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.3f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadingVenues{
    
    [_hud showWithString:@"Gathering Venues" maskType:WSProgressHUDMaskTypeDefault];
}

-(void)loadingTips{
    
    [_hud showWithString:@"Gathering Tips" maskType:WSProgressHUDMaskTypeDefault];
}

-(void)loadingProcessing{
    
    [_hud showWithString:@"Processing Tips" maskType:WSProgressHUDMaskTypeDefault];
}

-(void)loadingSenitments{
    
    [_hud showWithString:@"Finding Opinion" maskType:WSProgressHUDMaskTypeDefault];
}

-(void)dismissLoading{
    [_hud dismiss];
}

//static float progress = 0.0f;
//
//- (void)increaseProgress {
//    progress+=0.25f;
//    [WSProgressHUD showProgress:progress status:@"Updating..."];
//    
//    if(progress < 1.0f) {
//        [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.3f];
//    } else {
//        [WSProgressHUD showImage:nil status:@"Success Update"];
//        progress = 0;
//    }
//}

@end
