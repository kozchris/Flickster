//
//  Tag.h
//  Flickster
//
//  Created by Christopher Snyder on 8/15/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSSet *photo;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addPhotoObject:(Photo *)value;
- (void)removePhotoObject:(Photo *)value;
- (void)addPhoto:(NSSet *)values;
- (void)removePhoto:(NSSet *)values;

@end
