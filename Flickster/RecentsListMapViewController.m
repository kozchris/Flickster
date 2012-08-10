//
//  RecentsListMapViewController.m
//  Flickster
//
//  Created by Christopher Snyder on 8/10/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "RecentsListMapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "Common.h"
#import "PhotoViewController.h"

@interface RecentsListMapViewController ()

@end

@implementation RecentsListMapViewController

-(NSArray*)getAnnotations
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *photos = [defaults valueForKey:KEY_RECENT_PHOTOS];
    
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

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[super refreshData]
}

@end
