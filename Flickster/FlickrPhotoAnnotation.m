//
//  FlickerPhotoAnnotation.m
//  Flickster
//
//  Created by Christopher Snyder on 8/9/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "FlickrPhotoAnnotation.h"
#import "FlickrFetcher.h"

@interface FlickrPhotoAnnotation()
@end

@implementation FlickrPhotoAnnotation
@synthesize photo =_photo;
@synthesize thumbnailImage = _thumbnailImage;

-(NSDictionary*)photo
{
    return super.data;
}

-(void)setPhoto:(NSDictionary*)photo
{
    super.data = photo;
}

-(UIImage*) thumbnailImage
{
    NSURL *imageURL = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatSquare];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = imageData ? [[UIImage alloc] initWithData:imageData] : nil;
    return image;
}

+ (FlickrPhotoAnnotation*)annotationForPhoto:(NSDictionary *)photo
{
    FlickrPhotoAnnotation *annotation = [[FlickrPhotoAnnotation alloc] init];
    annotation.photo = photo;
    return annotation;
}

-(NSString*) title
{
    NSString *title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *description = [self.photo objectForKey:FLICKR_PHOTO_DESCRIPTION];
    
    if (title.length == 0)
    {
        title = description;
        description = @"";
    }
    
    if (title.length==0 && description.length ==0)
    {
        title = @"Unknown";
    }
    
    return title;
}

-(NSString*) subtitle
{
    NSString *title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *description = [self.photo objectForKey:FLICKR_PHOTO_DESCRIPTION];
    
    if (title.length == 0)
    {
        title = description;
        description = @"";
    }
    
    if (title.length==0 && description.length ==0)
    {
        title = @"Unknown";
    }
    
    return description;
}

@end
