//
//  PlacesTableViewController.m
//  Flickster
//
//  Created by Christopher Snyder on 8/3/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "PlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotosTableViewController.h"

@interface PlacesTableViewController ()
@property (nonatomic, strong) NSArray *places;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@end

@implementation PlacesTableViewController
@synthesize places = _places;
@synthesize refreshButton = _refreshButton;

-(void) setPlaces:(NSArray *)places
{
    if (_places!=places)
    {
        _places = places;
        [self.tableView reloadData];
    }
}

-(void)refreshTableData
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    
    UIBarButtonItem *origButton = self.refreshButton;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t getTopPlaces = dispatch_queue_create("get top places", NULL);
    dispatch_async(getTopPlaces, ^{
        NSArray *topPlaces = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.places = topPlaces;
            self.navigationItem.rightBarButtonItem = origButton;            
        });
    });
    dispatch_release(getTopPlaces);
}

- (IBAction)refreshClick:(UIBarButtonItem *)sender {
    [self refreshTableData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshTableData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setRefreshButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Display Photo Table"] )
    {
        UITableView *tableView = (UITableView*)self.view;
        
        PhotosTableViewController *photosViewController = segue.destinationViewController;
        
        photosViewController.place = [self.places objectAtIndex:tableView.indexPathForSelectedRow.row];
    }
}

#pragma mark - Table view data source

/*
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 {
 // Return the number of sections.
 return 0;
 }*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Places Table Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *place = [self.places objectAtIndex:indexPath.row];
    /*for (NSString *key in place.allKeys) {
     NSLog(@"key: %@ : %@", key, [place objectForKey:key]);
     }
     */
    
    NSArray *location = [(NSString*)[place objectForKey:@"_content"] componentsSeparatedByString:@", "];
    
    if (location.count >0)
    {
        cell.textLabel.text = [location objectAtIndex:0];
    }
    
    if (location.count>1)
    {
        NSRange theRange;
        theRange.location = 1;
        theRange.length = location.count-1;
        
        cell.detailTextLabel.text = [[location subarrayWithRange:theRange] componentsJoinedByString:@", "];
    }
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
    
    // Navigation logic may go here. Create and push another view controller.
    
    PhotosTableViewController *photosViewController = [[PhotosTableViewController alloc] init];
    photosViewController.place = [self.places objectAtIndex:indexPath.row];
    
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:photosViewController animated:YES];
    
}

@end
