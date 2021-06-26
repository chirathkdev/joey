//
//  SentimentAllocator.h
//  joey
//
//  Created by Chirath Kumarasiri on 2/12/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface SentimentAllocator : NSObject

-(void)initializeSentimentAllocatorOnCompletion:(void(^)(BOOL success)) completionBlock;

@end
