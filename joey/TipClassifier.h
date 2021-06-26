//
//  TipClassifier.h
//  joey
//
//  Created by Chirath Kumarasiri on 2/8/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "Parsimmon.h"

@interface TipClassifier : NSObject

- (void)initializeClassifier;

-(void)trainCategoryClassifier;
-(void)categoryDetector;

-(void)trainPolarityCalssifier;
-(NSString *)polarityDetectorWithString:(NSString *) string;

@end
