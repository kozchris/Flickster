//
//  FlickerPlaceAnnotation.m
//  Flickster
//
//  Created by Christopher Snyder on 8/9/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "FlickrPlaceAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrPlaceAnnotation
@synthesize place =_place;

-(NSDictionary*)place
{
    return super.data;
}

-(void)setPlace:(NSDictionary*)place
{
    super.data = place;
}

+ (FlickrPlaceAnnotation*)annotationForPlace:(NSDictionary *)place
{
    FlickrPlaceAnnotation *annotation = [[FlickrPlaceAnnotation alloc] init];
    annotation.place = place;
    return annotation;
}

-(NSString*) title
{
    NSArray *location = [(NSString*)[self.place objectForKey:FLICKR_PLACE_NAME] componentsSeparatedByString:@", "];
    NSString *title = @"Unknown";
    if (location.count >0)
    {
        title = [location objectAtIndex:0];
    }
    return title;
}

-(NSString*) subtitle
{
    NSArray *location = [(NSString*)[self.place objectForKey:FLICKR_PLACE_NAME] componentsSeparatedByString:@", "];
    NSString *subtitle;
    
    if (location.count>1)
    {
        NSRange theRange;
        theRange.location = 1;
        theRange.length = location.count-1;
        
        subtitle = [[location subarrayWithRange:theRange] componentsJoinedByString:@", "];
    }

    return subtitle;
}

@end
