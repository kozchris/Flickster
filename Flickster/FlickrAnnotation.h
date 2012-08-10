//
//  FlickrAnnotation.h
//  Flickster
//
//  Created by Christopher Snyder on 8/9/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrAnnotation : NSObject <MKAnnotation>
@property (nonatomic, strong) NSDictionary *data;

-(NSComparisonResult) compareLongitude:(id<MKAnnotation>) annotationToCompare ;
-(NSComparisonResult) compareLatitude:(id<MKAnnotation>) annotationToCompare;

@end
