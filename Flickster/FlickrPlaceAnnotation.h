//
//  FlickerPlaceAnnotation.h
//  Flickster
//
//  Created by Christopher Snyder on 8/9/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FlickrAnnotation.h"

@interface FlickrPlaceAnnotation : FlickrAnnotation

+ (FlickrPlaceAnnotation *)annotationForPlace:(NSDictionary*)place;

@property (nonatomic, strong) NSDictionary *place;

@end
