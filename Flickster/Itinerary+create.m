//
//  Itinerary+create.m
//  Flickster
//
//  Created by Christopher Snyder on 8/14/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "Itinerary+create.h"

@implementation Itinerary (create)

+(Itinerary*) itineraryWithTitle:(NSString*)title inManagedObjectContext:(NSManagedObjectContext*) context
{
    return [Itinerary itineraryWithTitle:title subTitle:@"" inManagedObjectContext:context];
}

+(Itinerary*) itineraryWithTitle:(NSString*)title subTitle:(NSString*)subTitle inManagedObjectContext:(NSManagedObjectContext*) context
{
    Itinerary *itinerary = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Itinerary"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", title];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
        NSLog(@"title match failure");
    } else if ([matches count] > 1) {
        NSLog(@"title matched multiples");
    }else if ([matches count] == 0) {
        itinerary = [NSEntityDescription insertNewObjectForEntityForName:@"Itinerary" inManagedObjectContext:context];
        itinerary.title = title;
        itinerary.subtitle = subTitle;
        itinerary.created = [NSDate date];
        itinerary.count = [[NSNumber alloc] initWithInt:0];
    } else {
        itinerary = [matches lastObject];
    }
    
    return itinerary;
}

@end
