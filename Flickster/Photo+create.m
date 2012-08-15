//
//  Photo+create.m
//  Flickster
//
//  Created by Christopher Snyder on 8/14/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "Photo+create.h"
#import "FlickrFetcher.h"
#import "Tag.h"
#import "Itinerary.h"
#import "Tag+create.h"

@implementation Photo (create)
+(Photo*) photoInItinerary:(Itinerary*)itinerary fromPhotoDictionary:(NSDictionary*)photoDictionary
{
    Photo *photo = nil;
    
    NSString *photoId = [photoDictionary valueForKeyPath:FLICKR_PHOTO_ID];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photoId = %@", photoId];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [itinerary.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!matches) {
        // handle error
        NSLog(@"photo match failure");
    } else if ([matches count] > 1) {
        NSLog(@"photo matched multiples");
    }else if ([matches count] == 0) {
        NSString *title = [photoDictionary objectForKey:FLICKR_PHOTO_TITLE];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *description = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        if (title.length == 0)
        {
            title = description;
            description = @"";
        }
        
        if (title.length==0 && description.length ==0)
        {
            title = @"Unknown";
        }
        
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:itinerary.managedObjectContext];
        photo.itinerary = itinerary;
        photo.itinerary.count = [[NSNumber alloc] initWithInt:[photo.itinerary.count intValue]+1];
        photo.photoId = photoId;
        photo.title = title;
        photo.subtitle = description;
        
        photo.farm = [photoDictionary objectForKey:@"farm"];
        photo.server = [photoDictionary objectForKey:@"server"];
        photo.secret = [photoDictionary objectForKey:@"secret"];
        photo.originalsecret = [photoDictionary objectForKey:@"originalsecret"];
        photo.originalformat = [photoDictionary objectForKey:@"originalformat"];
        
        //add tags associated to photo
        NSArray *tags = [(NSString*)[photoDictionary objectForKey:FLICKR_TAGS] componentsSeparatedByString:@" "] ;
        //uppercase first letter in each tag
        for(int tagIndex=0; tagIndex<tags.count; tagIndex++)
        {
            NSString *tagName = [[[tags objectAtIndex:tagIndex]
                                  capitalizedString]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            //skip any tag with a colon
            if (![tagName isEqualToString:@""] && [tagName rangeOfString:@":"].location==NSNotFound)
            {
                //see if tag exists
                request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
                request.predicate = [NSPredicate predicateWithFormat:@"name = %@", tagName];
                sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                
                matches = [itinerary.managedObjectContext executeFetchRequest:request error:&error];
                Tag *tag =nil;
                if (!matches)
                {
                    //handle error
                    NSLog(@"Error getting tag matches");
                }
                else if (matches.count>1)
                {
                    NSLog(@"Tag matched multiples");
                }
                else if (matches.count==1)
                {
                    //tag exists, update count and associate to photo
                    tag = [matches lastObject];
                }
                else
                {
                    tag = [Tag tagForName:tagName inManagedObjectContext:itinerary.managedObjectContext];
                }
                
                [photo addTagsObject:tag];
                tag.count = [[NSNumber alloc] initWithInt:[tag.count intValue] +1];
            }
        }
        
    } else {
        photo = [matches lastObject];
    }
    
    return photo;
}

-(NSDictionary *)FlickrPhotoFromPhoto
{
    NSDictionary *photo = [[NSDictionary alloc] initWithObjectsAndKeys:
                           self.photoId, FLICKR_PHOTO_ID,
                           self.title, FLICKR_PHOTO_TITLE,
                           self.subtitle, FLICKR_PHOTO_DESCRIPTION,
                           self.farm, @"farm",
                           self.server, @"server",
                           self.secret, @"secret",
                           self.originalsecret, @"originalsecret",
                           self.originalformat, @"originalformat",
                           nil];
    return photo;
}
@end
