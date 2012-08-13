//
//  FlickerPhotoAnnotation.h
//  Flickster
//
//  Created by Christopher Snyder on 8/9/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FlickrAnnotation.h"

@interface FlickrPhotoAnnotation : FlickrAnnotation

+ (FlickrPhotoAnnotation *)annotationForPhoto:(NSDictionary*)photo;

//return the thumbnail image cooresponding to this annotation
@property (nonatomic, strong, readonly) UIImage *thumbnailImage;
@property (nonatomic, strong) NSDictionary *photo;
@property (nonatomic, strong, readonly) NSString *photoId;
@end
