//
//  VenueStat.h
//  joey
//
//  Created by Chirath Kumarasiri on 2/2/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Realm/Realm.h>

@interface VenueStat : RLMObject

@property NSNumber<RLMInt> *checkinsCount;
@property NSNumber<RLMInt> *usersCount;
@property NSNumber<RLMInt> *tipcount;

@property NSNumber<RLMInt> *priceTier;
@property NSNumber<RLMDouble> *rating;

@property NSNumber<RLMBool> *isOpen;
@property NSNumber<RLMInt> *hereNow;

@end
