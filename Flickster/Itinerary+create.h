//
//  Itinerary+create.h
//  Flickster
//
//  Created by Christopher Snyder on 8/14/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "Itinerary.h"

@interface Itinerary (create)
+(Itinerary*) itineraryWithTitle:(NSString*)title inManagedObjectContext:(NSManagedObjectContext*) context;
+(Itinerary*) itineraryWithTitle:(NSString*)title subTitle:(NSString*)subTitle inManagedObjectContext:(NSManagedObjectContext*) context;
@end
