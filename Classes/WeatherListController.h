//
//  weatherListController.h
//  noaa
//
//  Created by Jennifer Pierce on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WeatherService.h"

@interface WeatherListController : UITableViewController  {

	NSArray *forecasts;
	WeatherService *weatherService;
}

//@property NSArray *forecasts;

@end
