//
//  PlacesListMapViewController.m
//  Flickster
//
//  Created by Christopher Snyder on 8/9/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "PlacesListMapViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPlaceAnnotation.h"
#import "PhotosListMapViewController.h"

@interface PlacesListMapViewController ()

@end

@implementation PlacesListMapViewController

-(NSArray*)getAnnotations
{
    NSArray *topPlaces = [FlickrFetcher topPlaces];
    
    //convert to annotations
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:topPlaces.count];
    for (NSDictionary *place in topPlaces)
    {
        [annotations addObject:[FlickrPlaceAnnotation annotationForPlace:place]];
    }
    return annotations;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Place Photos"] )
    {
        PhotosListMapViewController *photosListMapViewController = segue.destinationViewController;
        
        FlickrPlaceAnnotation *placeAnnotation = nil;
        
        if ([sender isKindOfClass:[MKMapView class]])
        {
            placeAnnotation = [self.mapView.selectedAnnotations lastObject];
        }
        else
        {
            placeAnnotation = [self.annotations objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        }
        
        photosListMapViewController.place = placeAnnotation.place;
    }
}

- (IBAction)listMapClick:(UISegmentedControl *)sender {
    return [super listMapClick:sender];
}

- (IBAction)refreshClick:(UIBarButtonItem *)sender {
    return [super refreshClick:sender];
}

@end
