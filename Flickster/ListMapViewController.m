//
//  ListMapViewController.m
//  Flickster
//
//  Created by Christopher Snyder on 8/8/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "Common.h"
#import "ListMapViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPlaceAnnotation.h"
#import "FlickrPhotoAnnotation.h"
#import <MapKit/MapKit.h>

@interface ListMapViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *listMapControl;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UIView *contentView;

typedef enum enumViewType { kList, kMap } enumViewType;
@end

@implementation ListMapViewController
@synthesize listMapControl = _listMapControl;
@synthesize tableView = _tableView;
@synthesize mapView = _mapView;
@synthesize refreshButton = _refreshButton;
@synthesize toolbar = _toolbar;
@synthesize contentView = _contentView;
@synthesize annotations = _annotations;

-(void) setAnnotations:(NSArray *)annotations
{
    if (_annotations!=annotations)
    {
        _annotations = annotations;
        
        [self.tableView reloadData];
        //reload map data
        if(self.mapView.annotations)
        {
            [self.mapView removeAnnotations:self.mapView.annotations];
        }
        
        [self.mapView addAnnotations:annotations];
        
        if (self.view.window)
        {
            if (self.annotations!=nil && self.annotations.count > 0)
            {
                //set map to view that will encompasis all annotations
                MKCoordinateRegion region = [self boundingCoordinateRegionForAnnotations];
                MKCoordinateRegion fitRegion = [self.mapView regionThatFits: region];
                [self.mapView setRegion: fitRegion animated: YES];
            }
        }
    }
}

-(NSArray*)getAnnotations
{
    //must implement in child
    return nil;
}

-(void)refreshData
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    
    UIBarButtonItem *origButton = self.refreshButton;
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy ];
    
    [toolbarItems removeLastObject];
    UIBarButtonItem *spinnerBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [toolbarItems addObject:spinnerBarButtonItem];
    self.toolbar.items = toolbarItems;
    
    dispatch_queue_t refreshListMap = dispatch_queue_create("refresh listmap", NULL);
    dispatch_async(refreshListMap, ^{
        NSArray *annotations = [self getAnnotations];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.annotations = annotations;
            
            [toolbarItems removeLastObject];
            [toolbarItems addObject:origButton];
            self.toolbar.items = toolbarItems;
        });
    });
    dispatch_release(refreshListMap);
}

//configure display for list or map view, using current listMapControl value
-(void) setListMapView
{
    if (self.listMapControl.selectedSegmentIndex == kList ) {
        self.tableView.frame = self.contentView.bounds;
        [self.contentView bringSubviewToFront:self.tableView];
    }
    else
    {
        //reload map data
        self.mapView.frame = self.contentView.bounds;
        [self.contentView bringSubviewToFront:self.mapView];
    }
}

- (IBAction)listMapClick:(UISegmentedControl *)sender {
    [self setListMapView];
    
    //save setting
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[[NSNumber alloc] initWithInt:self.listMapControl.selectedSegmentIndex] forKey:KEY_LIST_MAP_SELECTION];
    [defaults synchronize];
}

- (IBAction)refreshClick:(UIBarButtonItem *)sender {
    [self refreshData];
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
    return self.annotations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListMap Table Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    id<MKAnnotation> annotation = [self.annotations objectAtIndex:indexPath.row];
    if ([annotation isKindOfClass:[FlickrPlaceAnnotation class]])
    {
        
    }
    /*for (NSString *key in place.allKeys) {
     NSLog(@"key: %@ : %@", key, [place objectForKey:key]);
     }
     */
    
    cell.textLabel.text = annotation.title;
    cell.detailTextLabel.text = annotation.subtitle;
    
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
    
    //PhotosTableViewController *photosViewController = [[PhotosTableViewController alloc] init];
    //photosViewController.place = [self.places objectAtIndex:indexPath.row];
    
    // Pass the selected object to the new view controller.
    //[self.navigationController pushViewController:photosViewController animated:YES];
    
}

#pragma map - delegate
-(MKCoordinateRegion)boundingCoordinateRegionForAnnotations
{
    double north, south, east, west;
    NSArray *sortedAnnotations = [self.annotations sortedArrayUsingSelector:@selector(compareLongitude:)];
    id<MKAnnotation> tAnnotation = [sortedAnnotations objectAtIndex:0];
    west = tAnnotation.coordinate.longitude;
    tAnnotation = [sortedAnnotations lastObject];
    east = tAnnotation.coordinate.longitude;
    
    sortedAnnotations = [self.annotations sortedArrayUsingSelector:@selector(compareLatitude:)];
    tAnnotation = [sortedAnnotations objectAtIndex:0];
    south = tAnnotation.coordinate.latitude;
    tAnnotation = [sortedAnnotations lastObject];
    north = tAnnotation.coordinate.latitude;
    
    // Now that we have a min and max lat/lon create locations for the
    // three points in a right triangle
    CLLocation* locSouthWest = [[CLLocation alloc]
                                initWithLatitude: south
                                longitude: west];
    CLLocation* locSouthEast = [[CLLocation alloc]
                                initWithLatitude: south
                                longitude: east];
    CLLocation* locNorthEast = [[CLLocation alloc]
                                initWithLatitude: north
                                longitude: east];
    
    // Create a region centered at the midpoint of our hypotenuse
    CLLocationCoordinate2D regionCenter;
    regionCenter.latitude = (north + south) / 2.0;
    regionCenter.longitude = (west + east) / 2.0;
    
    // Use the locations that we just created to calculate the distance
    // between each of the points in meters.
    CLLocationDistance latMeters = [locSouthEast distanceFromLocation: locNorthEast];
    CLLocationDistance lonMeters = [locSouthEast distanceFromLocation: locSouthWest];
    
    MKCoordinateRegion region;
    region = MKCoordinateRegionMakeWithDistance( regionCenter, latMeters, lonMeters );
    
    return region;
}

-(MKAnnotationView*)mapView:(MKMapView*)sender viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString *annotationIdentifier = @"Annotation Identifier";
    MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!aView)
    {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        aView.canShowCallout = YES;
        
        //UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30) ];
        //UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rightarrow" ofType:@"png"]];
        //[button setImage:image forState:UIControlStateNormal];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@">" forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, 30, 30);
        
        aView.rightCalloutAccessoryView = button;
    }
    
    if ([aView.annotation isKindOfClass:[FlickrPhotoAnnotation class]])
    {
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30,30)];
        [(UIImageView*)aView.leftCalloutAccessoryView setImage:nil];
    }
    else if ([aView.annotation isKindOfClass:[FlickrPlaceAnnotation class]])
    {
        /*aView.rightCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30,30)];
         UIImageView *imageView = (UIImageView*)aView.rightCalloutAccessoryView;
         UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rightarrow" ofType:@"png"]];
         imageView.image = image;*/
    }
    
    
    aView.annotation = annotation;
    
    return aView;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]])
    {
        UIImageView *imageView = (UIImageView*)view.leftCalloutAccessoryView;
        if (imageView)
        {
            if ([view.annotation isKindOfClass:[FlickrPhotoAnnotation class]])
            {
                FlickrPhotoAnnotation *annotation = view.annotation;
                UIImage *image = annotation.thumbnailImage ;
                imageView.image = image;
            }
        }
    }
}

-(void)mapPhotoAnnotationSelected:(FlickrPhotoAnnotation*)photoAnnotation sender:(MKMapView*)mapView
{
    return;
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (self.navigationController.parentViewController.splitViewController != nil)
    {
        if ([view.annotation isKindOfClass:[FlickrPlaceAnnotation class]])
        {
            //segue to photos
            [self performSegueWithIdentifier:@"Show Place Photos" sender:self.mapView];
        }
        else if ([view.annotation isKindOfClass:[FlickrPhotoAnnotation class]])
        {
            [self mapPhotoAnnotationSelected:view.annotation sender:self.mapView];
        }
    }
    else
    {
        if ([view.annotation isKindOfClass:[FlickrPlaceAnnotation class]])
        {
            //segue to photos
            [self performSegueWithIdentifier:@"Show Place Photos" sender:self.mapView];
        }
        else if ([view.annotation isKindOfClass:[FlickrPhotoAnnotation class]])
        {
            //segue to photo
            [self performSegueWithIdentifier:@"Display Photo" sender:self.mapView];
        }
    }
}

#pragma mark - init / load

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //init listMap control
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *listMapSelection = [defaults valueForKey:KEY_LIST_MAP_SELECTION];
    if(listMapSelection==nil)
    {
        listMapSelection = [[NSNumber alloc] initWithInt:kList];
    }
    
    [defaults setValue:listMapSelection forKey:KEY_LIST_MAP_SELECTION];
    [defaults synchronize];
    
    self.listMapControl.selectedSegmentIndex = [listMapSelection intValue];
    
    [self refreshData];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //init view
    [self setListMapView];
}

- (void)viewDidUnload
{
    [self setListMapControl:nil];
    [self setTableView:nil];
    [self setMapView:nil];
    [self setRefreshButton:nil];
    [self setToolbar:nil];
    [self setContentView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
