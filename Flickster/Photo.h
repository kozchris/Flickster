//
//  Photo.h
//  Flickster
//
//  Created by Christopher Snyder on 8/15/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Itinerary, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photoId;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * farm;
@property (nonatomic, retain) NSString * server;
@property (nonatomic, retain) NSString * secret;
@property (nonatomic, retain) NSString * originalsecret;
@property (nonatomic, retain) NSString * originalformat;
@property (nonatomic, retain) Itinerary *itinerary;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
