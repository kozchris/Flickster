//
//  PhotoListMapViewController.m
//  Flickster
//
//  Created by Christopher Snyder on 8/9/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "Common.h"
#import "PhotosListMapViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoAnnotation.h"
#import "PhotoViewController.h"

@interface PhotosListMapViewController ()

@end

@implementation PhotosListMapViewController
@synthesize placeAnnotation = _placeAnnotation;

-(void) setPlace:(FlickrPlaceAnnotation *)placeAnnotation
{
    if (_placeAnnotation != placeAnnotation)
    {
        _placeAnnotation = placeAnnotation;
        
        self.title = self.placeAnnotation.title;
        
        if (self.view.window)
        {
            [self refreshData];
        }
    }
}

-(NSArray*)getAnnotations
{
    NSArray *photos = [FlickrFetcher photosInPlace:self.placeAnnotation.place maxResults:MAX_PLACE_PHOTO_RESULTS];
    
    //convert to annotations
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:photos.count];
    for (NSDictionary *photo in photos)
    {
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Display Photo"] )
    {
        PhotoViewController *photoViewController = segue.destinationViewController;
       
        FlickrPhotoAnnotation *photoAnnotation = nil;
        
        if ([sender isKindOfClass:[MKMapView class]])
        {
            photoAnnotation = [self.mapView.selectedAnnotations lastObject];
        }
        else
        {
            photoAnnotation = [self.annotations objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        }
        photoViewController.photo = photoAnnotation.photo;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlickrPhotoAnnotation *photoAnnotation = [self.annotations objectAtIndex:indexPath.row];
    
    if (self.navigationController.parentViewController.splitViewController != nil)
    {
        PhotoViewController *photoViewController = [self.navigationController.parentViewController.splitViewController.viewControllers lastObject];
        photoViewController.photo = photoAnnotation.photo;
    }
}

-(void)mapPhotoAnnotationSelected:(FlickrPhotoAnnotation*)photoAnnotation sender:(MKMapView*)mapView
{
    if (self.navigationController.parentViewController.splitViewController != nil)
    {
        PhotoViewController *photoViewController = [self.navigationController.parentViewController.splitViewController.viewControllers lastObject];
        photoViewController.photo = photoAnnotation.photo;
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.placeAnnotation.title;
}
@end
