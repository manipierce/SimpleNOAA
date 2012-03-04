//
//  ForecastParser.m
//  noaa
//
//  Created by Jennifer Pierce on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ForecastParser.h"

const NSString *SummaryKey = @"summary";
const NSString *TimeNameKey = @"time-name";
const NSString *PrecipitationProbabilityKey = @"precipitation-probability";
const NSString *TemperatureKey = @"temperature";
const NSString *ExtendedSummaryKey = @"extended-summary";

static const NSString *Tonight = @"Tonight";
static const NSString *Today = @"Today";
static const NSString *MinimumTemp = @"minimum";
static const NSString *MaximumTemp = @"maximum";

static const NSString *DataElement = @"data";
static const NSString *DataTypeAttribute = @"type";
static const NSString *TextElement = @"text";
static const NSString *ForecastDataType = @"forecast";

static const NSString *ValueElement = @"value";

static const NSString *LayoutKeyElement = @"layout-key";
static const NSString *TimeLayoutKeyAttribute = @"time-layout";
static const NSString *TimeLayoutDayAndNightKey1 = @"k-p12h-n14-1";
static const NSString *TimeLayoutDayAndNightKey2 = @"k-p12h-n13-1";

static const NSString *TimeLayoutElement = @"time-layout";
static const NSString *StartValidTimeElement = @"start-valid-time";
static const NSString *TimePeriodNameAttribute = @"period-name";

static const NSString *TemperatureElement = @"temperature";

static const NSString *PrecipitationProbabilityElement = @"probability-of-precipitation";

static const NSString *WeatherElement = @"weather";
static const NSString *WeatherConditionsElement = @"weather-conditions";
static const NSString *WeatherSummaryAttribute = @"weather-summary";

static const NSString *WordedForecastElement = @"wordedForecast";

NSMutableString *currentContent;
BOOL parsingForecastData;
BOOL parsingWeather;
BOOL parsingPrecipitation;
BOOL parsingTemperature;
BOOL parsingWordedForecasts;
BOOL parsingTimePeriods;
BOOL startsToday; // as opposed to Tonight
NSMutableArray *parsedForecasts;
short forecastIndexCounter;

@implementation ForecastParser

- (NSArray *) getParsedForecasts {
	
	return parsedForecasts;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	
	parsedForecasts = [[NSMutableArray alloc] initWithCapacity:0];
	
	parsingForecastData = FALSE;
	parsingWeather = FALSE;
	parsingPrecipitation = FALSE;
	parsingTemperature = FALSE;
	parsingWordedForecasts = FALSE;
	parsingTimePeriods = FALSE;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
	NSLog(@"Ended Parsing");
}

- (void)parser:(NSXMLParser *)parser didStartElement:
		(NSString *)elementName 
		namespaceURI:(NSString *)namespaceURI 
		qualifiedName:(NSString *)qName 
		attributes:(NSDictionary *)attributeDict {
	
	//NSLog([NSString stringWithFormat:@"Start element: %@", elementName]);
	
	if ([elementName compare:DataElement] == NSOrderedSame)
	{
		NSString *dataType = [attributeDict objectForKey:DataTypeAttribute];
		if ([ForecastDataType compare:dataType] == NSOrderedSame)
		{
			parsingForecastData = TRUE;
			return;
		}
	}
	if (parsingForecastData == FALSE)
	{
		return;
	}
	else if ([elementName compare:TimeLayoutElement] == NSOrderedSame)
	{
		parsingTimePeriods = TRUE;
	}
	else if ((parsingTimePeriods == TRUE) && ([elementName compare:LayoutKeyElement] == NSOrderedSame))
	{
		currentContent = [[NSMutableString alloc] initWithCapacity:0];
	}
	else if ((parsingTimePeriods == TRUE) && ([elementName compare:StartValidTimeElement] == NSOrderedSame))
	{
		NSString *attr = [attributeDict objectForKey:TimePeriodNameAttribute];
		NSLog(attr);
		if (attr == nil)
		{
			NSLog(@"found nil time period name");
		}
		
		NSMutableDictionary *newForecast = [[NSMutableDictionary alloc] initWithCapacity:14];
		[newForecast setObject:attr forKey:TimeNameKey];
		
		[parsedForecasts addObject:newForecast];
		
		if ([attr compare:Today] == NSOrderedSame)
		{
			startsToday = TRUE;
		}
		else 
		{
			startsToday = FALSE;
		}

	}
	else if ([elementName compare:WeatherElement] == NSOrderedSame) 
	{
		parsingWeather = TRUE;
		forecastIndexCounter = 0;
	}
	else if ((parsingWeather == TRUE) && ([elementName compare:WeatherConditionsElement] == NSOrderedSame))
	{
		NSString *attr = [attributeDict objectForKey:WeatherSummaryAttribute];
		NSLog(attr);
		if (attr == nil)
		{
			NSLog(@"found nil weather summary");
		}
		
		NSMutableDictionary *currentForecast = [parsedForecasts objectAtIndex:forecastIndexCounter];
		[currentForecast setObject:attr forKey:SummaryKey];
		[currentForecast release];
		forecastIndexCounter++;
	
	}
	else if ([elementName compare:PrecipitationProbabilityElement] == NSOrderedSame)
	{
		parsingPrecipitation = TRUE;
		forecastIndexCounter = 0;
	}
	else if ((parsingPrecipitation == TRUE) && ([elementName compare:ValueElement] == NSOrderedSame))
	{
		currentContent = [[NSMutableString alloc] initWithCapacity:0];
	}
	else if ([elementName compare:TemperatureElement] == NSOrderedSame)
	{
		parsingTemperature = TRUE;
		
		NSString *temperatureType = [attributeDict objectForKey:DataTypeAttribute];
		
		BOOL isMinimumTemperatures = [temperatureType compare:MinimumTemp] == NSOrderedSame;
		
		if (startsToday = TRUE)
		{
			forecastIndexCounter = isMinimumTemperatures ? 1 : 0;
		}
		else 
		{
			forecastIndexCounter = isMinimumTemperatures ? 0 : 1;
		}
	}
	else if ((parsingTemperature == TRUE) && ([elementName compare:ValueElement] == NSOrderedSame))
	{
		currentContent = [[NSMutableString alloc] initWithCapacity:0];
	}
	else if ([elementName compare:WordedForecastElement] == NSOrderedSame)
	{
		parsingWordedForecasts = TRUE;
		forecastIndexCounter = 0;
	}
	else if ([elementName compare:TextElement] == NSOrderedSame)
	{
		currentContent = [[NSMutableString alloc] initWithCapacity:0];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:
		(NSString *)elementName 
		namespaceURI:(NSString *)namespaceURI 
		qualifiedName:(NSString *)qName {
	
	//NSLog([NSString stringWithFormat:@"End element: %@", elementName]);
	if ([elementName compare:DataElement] == NSOrderedSame)
	{
		parsingForecastData = FALSE;
	}		
	else if ([elementName compare:WeatherElement] == NSOrderedSame)
	{
		parsingWeather = FALSE;
	}
	else if ([elementName compare:TimeLayoutElement] == NSOrderedSame)
	{
		parsingTimePeriods = FALSE;
	}
	else if ([elementName compare:PrecipitationProbabilityElement] == NSOrderedSame)
	{
		parsingPrecipitation = FALSE;
	}
	else if ([elementName compare:TemperatureElement] == NSOrderedSame)
	{
		parsingTemperature = FALSE;
	}
	else if ([elementName compare:WordedForecastElement] == NSOrderedSame)
	{
		parsingWordedForecasts = FALSE;
	}
	else if ((parsingTimePeriods == TRUE) && ([elementName compare:LayoutKeyElement] == NSOrderedSame))
	{
		if (currentContent != nil)
		{
			if (([currentContent compare:TimeLayoutDayAndNightKey1] != NSOrderedSame) && ([currentContent compare:TimeLayoutDayAndNightKey2] != NSOrderedSame)) 
			{
				parsingTimePeriods = FALSE;
			}
			[currentContent release];
			currentContent = nil;
		}
	}
	else if ((parsingPrecipitation == TRUE) && ([elementName compare:ValueElement] == NSOrderedSame))
	{
		if (currentContent != nil)
		{
			NSLog(@"precipitation index: %d", forecastIndexCounter);
			NSMutableDictionary *currentForecast = [parsedForecasts objectAtIndex:forecastIndexCounter];
			[currentForecast setObject:currentContent forKey:PrecipitationProbabilityKey];
			//[currentForecast release];
			forecastIndexCounter++;
			
			[currentContent release];
			currentContent = nil;	
		}
	}
	else if ((parsingTemperature == TRUE) && ([elementName compare:ValueElement] == NSOrderedSame))
	{
		if (currentContent != nil)
		{
			NSLog(@"temperature index: %d", forecastIndexCounter);
			NSMutableDictionary *currentForecast = [parsedForecasts objectAtIndex:forecastIndexCounter];
			[currentForecast setObject:currentContent forKey:TemperatureKey];
			//[currentForecast release];
			forecastIndexCounter += 2;
			
			[currentContent release];
			currentContent = nil;
		}
	}
	else if ((parsingWordedForecasts == TRUE) && ([elementName compare:TextElement] == NSOrderedSame))
	{
		if (currentContent != nil)
		{
			NSLog(@"worded forecast index: %d", forecastIndexCounter);
			NSMutableDictionary *currentForecast = [parsedForecasts objectAtIndex:forecastIndexCounter];
			[currentForecast setObject:currentContent forKey:ExtendedSummaryKey];
			//[currentForecast release];
			forecastIndexCounter++;
			
			[currentContent release];
			currentContent = nil;
		}
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	if (currentContent && string) 
	{
		[currentContent appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	NSLog(@"parseErrorOccurred: %s", [parseError localizedDescription]);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
	
	NSLog(@"validationErrorOccurred");
}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID {}
- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {}
- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data {}
- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {}
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {}
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID {}
- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName {}
- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue {}
- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model {}
- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value {}
- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID {}
- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {}
- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix {}

@end
