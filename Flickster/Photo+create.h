//
//  Photo+create.h
//  Flickster
//
//  Created by Christopher Snyder on 8/14/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "Photo.h"

@interface Photo (create)
+(Photo*) photoInItinerary:(Itinerary*)itinerary fromPhotoDictionary:(NSDictionary*)photoDictionary;
-(NSDictionary *)FlickrPhotoFromPhoto;
@end
