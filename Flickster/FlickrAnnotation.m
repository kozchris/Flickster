//
//  FlickrAnnotation.m
//  Flickster
//
//  Created by Christopher Snyder on 8/9/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "FlickrAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrAnnotation
@synthesize data = _data;

-(NSComparisonResult) compareLongitude:(FlickrAnnotation*) annotationToCompare
{
    
    NSComparisonResult result = NSOrderedSame;
    if (self.coordinate.longitude > annotationToCompare.coordinate.longitude )
    {
        result = NSOrderedDescending;
    }
    else if (self.coordinate.longitude < annotationToCompare.coordinate.longitude)
    {
        result = NSOrderedAscending;
    }
    
    return result;
}

-(NSComparisonResult) compareLatitude:(FlickrAnnotation*) annotationToCompare
{
    
    NSComparisonResult result = NSOrderedSame;
    if (self.coordinate.latitude > annotationToCompare.coordinate.latitude )
    {
        result = NSOrderedDescending;
    }
    else if (self.coordinate.latitude < annotationToCompare.coordinate.latitude)
    {
        result = NSOrderedAscending;
    }
    
    return result;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.data valueForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.data valueForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}
@end
