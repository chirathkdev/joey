//
//  ComponentConnector.h
//  joey
//
//  Created by Chirath Kumarasiri on 2/26/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "LoadingViewController.h"

@interface ComponentConnector : NSObject

-(void) initializeComponentConnectorWithLoadingView:(LoadingViewController *) loadingViewController completion:(void(^)(BOOL success)) completionBlock;

@end
