//
//  weatherListController.m
//  noaa
//
//  Created by Jennifer Pierce on 3/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WeatherListController.h"
#import "WeatherService.h"
#import "ForecastParser.h"


@implementation WeatherListController

//@synthesize forecasts;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	weatherService = [WeatherService alloc];
	[weatherService loadForecast];
	[weatherService retain];

	forecasts = [weatherService getForecasts];
	//forecasts = [NSArray arrayWithObjects:
	//			 [NSDictionary dictionaryWithObjectsAndKeys:
	//			  @"One", @"titleValue", nil],
	//			 [NSDictionary dictionaryWithObjectsAndKeys:
	//			  @"Two", @"titleValue", nil],
	//			 [NSDictionary dictionaryWithObjectsAndKeys:
	//			  @"Three", @"titleValue", nil],
	//			 nil];
	[forecasts retain];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	return YES;
//    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation);
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	return forecasts.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
	NSDictionary *forecast = [forecasts	objectAtIndex:section];
	
	if (forecast == nil)
	{
		return @"No forecast found";
	}
	else
	{
		return [NSString stringWithFormat:@"%@: %@%% %@d %@", 
							   [forecast objectForKey:TimeNameKey],
							   [forecast objectForKey:PrecipitationProbabilityKey],
							   [forecast objectForKey:TemperatureKey],
							   [forecast objectForKey:SummaryKey]];
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    	cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
	}
    
	NSDictionary *forecast = [forecasts objectAtIndex:indexPath.section];
	
	if (forecast == nil)
	{
		cell.textLabel.text = @"No forecast found";
	}
	else
	{
		cell.textLabel.text = [forecast objectForKey:ExtendedSummaryKey];
	}
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *forecast = [forecasts objectAtIndex:indexPath.section];
	
    NSString *cellText = [forecast objectForKey:ExtendedSummaryKey];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	
    return labelSize.height + 20;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
	[weatherService dealloc];
	[forecasts dealloc];
    [super dealloc];
}

@end

