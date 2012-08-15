//
//  Vacation.h
//  Flickster
//
//  Created by Christopher Snyder on 8/15/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Itinerary;

@interface Vacation : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *itineraries;
@end

@interface Vacation (CoreDataGeneratedAccessors)

- (void)addItinerariesObject:(Itinerary *)value;
- (void)removeItinerariesObject:(Itinerary *)value;
- (void)addItineraries:(NSSet *)values;
- (void)removeItineraries:(NSSet *)values;

@end
