//
//  PhotosTableViewController.m
//  Flickster
//
//  Created by Christopher Snyder on 8/5/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "PhotosTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

#define MAX_RESULTS 50

@interface PhotosTableViewController ()
@property (nonatomic, strong) NSArray* photos;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@end

@implementation PhotosTableViewController
@synthesize photos = _photos;
@synthesize refreshButton = _refreshButton;
@synthesize place = _place;

-(void) setPhotos:(NSArray *)photos
{
    if(_photos!=photos)
    {
        _photos = photos;
        [self.tableView reloadData];
    }
}

-(void) setPlace:(NSDictionary *)place
{
    if (_place != place)
    {
        _place = place;
        [self refreshTableData];
    }
}

-(void)refreshTableData
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    
    UIBarButtonItem *origButton = self.refreshButton;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t getPhotosInPlace = dispatch_queue_create("get photos in place", NULL);
    dispatch_async(getPhotosInPlace, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:MAX_RESULTS];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = photos;
            self.navigationItem.rightBarButtonItem = origButton;
        });
    });
    dispatch_release(getPhotosInPlace);
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
    if([segue.identifier isEqualToString:@"Display Photo"] )
    {
        UITableView *tableView = (UITableView*)self.view;
        
        PhotoViewController *photoViewController = segue.destinationViewController;
        
        photoViewController.photo = [self.photos objectAtIndex:tableView.indexPathForSelectedRow.row];
        
        UITableViewCell *cell = (UITableViewCell*)sender;
        photoViewController.title =cell.textLabel.text;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Table Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    /*for (NSString *key in photo.allKeys) {
     NSLog(@"key: %@ : %@", key, [photo objectForKey:key]);
     }
     */
    
    NSString *title = [photo objectForKey:@"title"];
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *description = [[photo objectForKey:@"description"] objectForKey:@"_content"];
    
    if (title.length == 0)
    {
        title = description;
        description = @"";
    }
    
    if (title.length==0 && description.length ==0)
    {
        title = @"Unknown";
    }
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = description;
    
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
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    if (self.navigationController.parentViewController.splitViewController != nil)
    {
        PhotoViewController *photoViewController = [self.navigationController.parentViewController.splitViewController.viewControllers lastObject];
        photoViewController.photo = photo;
    }
}

@end
