//
//  Itinerary.h
//  Flickster
//
//  Created by Christopher Snyder on 8/15/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Vacation;

@interface Itinerary : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) Vacation *vacation;
@end

@interface Itinerary (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
