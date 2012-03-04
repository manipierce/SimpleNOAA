//
//  WeatherService.h
//  noaa
//
//  Created by Jennifer Pierce on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WeatherService : NSObject {

	NSArray *forecasts;
	NSMutableData *receivedData;
}

- (void)loadForecast;
- (NSArray *)getForecasts;

@end
