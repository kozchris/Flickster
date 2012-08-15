//
//  Vacation+create.h
//  Flickster
//
//  Created by Christopher Snyder on 8/13/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "Vacation.h"

@interface Vacation (create)
+(Vacation*) vacationWithName:(NSString*)name inManagedObjectContext:(NSManagedObjectContext*) context;
@end
