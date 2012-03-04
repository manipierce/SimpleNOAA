//
//  ForecastParser.h
//  noaa
//
//  Created by Jennifer Pierce on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ForecastParser : NSObject {
	
}

extern const NSString *SummaryKey;
extern const NSString *TimeNameKey;
extern const NSString *PrecipitationProbabilityKey;
extern const NSString *TemperatureKey;
extern const NSString *ExtendedSummaryKey;

- (NSArray *) getParsedForecasts;

@end
