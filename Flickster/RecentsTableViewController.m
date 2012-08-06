//
//  RecentsTableViewController.m
//  Flickster
//
//  Created by Christopher Snyder on 8/3/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "RecentsTableViewController.h"
#import "FlickrFetcher.h"
#import "Common.h"
#import "PhotoViewController.h"

@interface RecentsTableViewController ()
@property (nonatomic, strong) NSArray *recentPhotos;
@end

@implementation RecentsTableViewController
@synthesize recentPhotos = _recentPhotos;

-(void) setRecentPhotos:(NSArray *)recentPhotos
{
    _recentPhotos = recentPhotos;
    [self.tableView reloadData];
}

-(NSArray*) recentPhotos
{
    if(_recentPhotos==nil)
    {
        
    }
    
    return _recentPhotos;
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
     
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //init table data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.recentPhotos = [defaults valueForKey:KEY_RECENT_PHOTOS];
}

- (void)viewDidUnload
{
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
    if([segue.identifier isEqualToString:@"Show Recent Photo"] )
    {
        UITableView *tableView = (UITableView*)self.view;
        
        PhotoViewController *photoViewController = segue.destinationViewController;
        
        photoViewController.photo = [self.recentPhotos objectAtIndex:tableView.indexPathForSelectedRow.row];
        
        UITableViewCell *cell = (UITableViewCell*)sender;
        photoViewController.title =cell.textLabel.text;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.recentPhotos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recents Table Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *photo = [self.recentPhotos objectAtIndex:indexPath.row];
    
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
    NSDictionary *photo = [self.recentPhotos objectAtIndex:indexPath.row];
    
    if (self.navigationController.parentViewController.splitViewController != nil)
    {
        PhotoViewController *photoViewController = [self.navigationController.parentViewController.splitViewController.viewControllers lastObject];
        photoViewController.photo = photo;
    }
}

@end
