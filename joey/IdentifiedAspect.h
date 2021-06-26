//
//  IdentifiedAspect.h
//  joey
//
//  Created by Chirath Kumarasiri on 2/5/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Realm/Realm.h>

@interface IdentifiedAspect : RLMObject

@property NSString *tipId;
@property NSString *aspectTypeMain;
@property NSString *aspectTypeSub;
@property NSString *aspect;
@property NSString *trend;
@property NSInteger aspectWeight;

@end

RLM_ARRAY_TYPE(IdentifiedAspect)

