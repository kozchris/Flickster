//
//  Tag+create.m
//  Flickster
//
//  Created by Christopher Snyder on 8/14/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "Tag+create.h"
#import "Photo.h"

@implementation Tag (create)
+(Tag*) tagForName:(NSString*)name inManagedObjectContext:(NSManagedObjectContext*) context
{
    Tag *tag = nil;
    
    //uppercase first char
    
    NSString *tagName = [[name capitalizedString]
                         stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![tagName isEqualToString:@""] && [tagName rangeOfString:@":"].location==NSNotFound)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", tagName];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        NSError *error = nil;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches) {
            // handle error
            NSLog(@"tag match failure");
        } else if ([matches count] > 1) {
            NSLog(@"tag matched multiples");
        }else if ([matches count] == 0) {
            tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
            tag.name = tagName;
            tag.count = [[NSNumber alloc] initWithInt:0];
        } else {
            tag = [matches lastObject];
        }
    }
    return tag;
}
@end
