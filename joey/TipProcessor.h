//
//  TipProcessor.h
//  joey
//
//  Created by Chirath Kumarasiri on 1/30/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface TipProcessor : NSObject

-(void)initializeProcessorOnCompletion:(void(^)(BOOL success)) completionBlock;

@end
