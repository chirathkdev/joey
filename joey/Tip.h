//
//  Tip.h
//  joey
//
//  Created by Chirath Kumarasiri on 2/2/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Realm/Realm.h>

@interface Tip : RLMObject

@property NSString *tipId;
@property NSString *tipText;
@property NSString *normalizedTipText;
@property NSString *tipWithDishNameText;

@property NSInteger tipSentiment;

@property NSNumber<RLMInt> *createdAt;
@property NSNumber<RLMInt> *likes;
@property NSNumber<RLMInt> *agreeCount;
@property NSNumber<RLMInt> *disagreeCount;

@end

RLM_ARRAY_TYPE(Tip)
