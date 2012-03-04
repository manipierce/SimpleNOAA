//
//  WeatherService.m
//  noaa
//
//  Created by Jennifer Pierce on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WeatherService.h"
#import "ForecastParser.h"

ForecastParser *forecastParser;

@implementation WeatherService

- (void)loadForecast {
	
	NSString *noaaURLString = [NSString alloc];
	noaaURLString = @"http://forecast.weather.gov/MapClick.php?lat=41.50960&lon=-81.56350&FcstType=dwml";
	//noaaURLString = @"http://forecast.weather.gov/MapClick.php?CityName=Cleveland+Heights&state=OH&site=CLE&textField1=41.5096&textField2=-81.5635&e=0";
	//noaaURLString = @"http://www.google.com";	
	
	NSURL *noaaURL = [NSURL URLWithString:noaaURLString];
	
	NSURLRequest *noaaURLRequest = [NSURLRequest requestWithURL:noaaURL];
	
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:noaaURLRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		receivedData = [[NSMutableData data] retain];
	} else {
		NSLog(@"Connection failed");
	}
	
	//NSLog(@"received Data length: %d", [receivedData length]);
	
	NSString *stringData = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:noaaURLString]];
	
	NSData *data =[stringData dataUsingEncoding:NSISOLatin1StringEncoding];
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	
	forecastParser = [ForecastParser alloc];
	[parser setDelegate:forecastParser];
	[parser parse];
	 
	forecasts = @"FORECAST";
	
	[parser release];
}

- (NSArray *)getForecasts {

	return [forecastParser getParsedForecasts];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // This method is called when the server has determined that it 
	// has enough information to create the NSURLResponse.
	// It can be called multiple times, for example in the case of a redirect, so each time we reset the data.
	
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to receivedData.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // release the connection, and the data object
    [connection release];
    [receivedData release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
	
    //NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	//NSLog([[NSString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding]);
	//NSXMLParser *parser = [[NSXMLParser alloc] initWithData:receivedData];
	//NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:noaaURLString]];
	
    // release the connection, and the data object
	
    [connection release];
    [receivedData release];
}
@end
