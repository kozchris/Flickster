//
//  Vacation+create.m
//  Flickster
//
//  Created by Christopher Snyder on 8/13/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "Vacation+create.h"

@implementation Vacation (create)

+(Vacation*) vacationWithName:(NSString*)name inManagedObjectContext:(NSManagedObjectContext*) context
{
    Vacation *vacation = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Vacation"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
        NSLog(@"vacation match failure");
    } else if ([matches count] > 1) {
        NSLog(@"vacation matched multiples");
    }else if ([matches count] == 0) {
        vacation = [NSEntityDescription insertNewObjectForEntityForName:@"Vacation" inManagedObjectContext:context];
        vacation.name = name;
    } else {
        vacation = [matches lastObject];
    }
    
    return vacation;
}

@end
