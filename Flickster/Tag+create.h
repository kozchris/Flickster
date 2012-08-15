//
//  Tag+create.h
//  Flickster
//
//  Created by Christopher Snyder on 8/14/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "Tag.h"

@interface Tag (create)
+(Tag*) tagForName:(NSString*)name inManagedObjectContext:(NSManagedObjectContext*) context;
@end
