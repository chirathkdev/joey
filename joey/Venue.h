//
//  Venue.h
//  joey
//
//  Created by Chirath Kumarasiri on 2/2/17.
//  Copyright © 2017 Chirath Kumarasiri. All rights reserved.
//

#import <Realm/Realm.h>
#import "VenueInfo.h"
#import "VenueStat.h"
#import "Tip.h"
#import "IdentifiedAspect.h"

@interface Venue : RLMObject

@property NSString *venueId;
@property VenueInfo *venueInfo;
@property VenueStat *venueStat;

@property NSInteger venueSentiment;

@property RLMArray <Tip> *tips;

@property RLMArray <IdentifiedAspect> *identifiedAspects;

@end

