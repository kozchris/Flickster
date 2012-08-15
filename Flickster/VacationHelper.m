//
//  VacationHelper.m
//  Flickster
//
//  Created by Christopher Snyder on 8/12/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "VacationHelper.h"
#import <CoreData/CoreData.h>
#import "Vacation.h"
#import "Vacation+create.h"

@interface VacationHelper ()

@end

@implementation VacationHelper
static NSMutableDictionary *vacationDocuments;

+ (Vacation*) getVacationForName:(NSString*)name context:(NSManagedObjectContext*)context
{
    Vacation *vacation;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Vacation"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if(!matches)
    {
        NSLog(@"getVacationForName matches error");
    }
    else if (matches.count>1)
    {
        NSLog(@"Too many vacations");
    }
    else if (matches.count == 1)
    {
        vacation = [matches lastObject];
    }
    else
    {
        //init vacation
        vacation = [Vacation vacationWithName:name inManagedObjectContext:context];
    }
    
    return vacation;
}

+ (void)openVacation:(NSString *)vacationName
          usingBlock:(completion_block_t)completionBlock
{
    //vacation document storage
    if (vacationDocuments==nil)
    {
        vacationDocuments = [[NSMutableDictionary alloc] init];
    }
    
    UIManagedDocument *vacationDocument = [vacationDocuments objectForKey:vacationName];
    
    if (vacationDocument==nil)
    {
        //check for vacation file in documents directory
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSURL *documentURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask ] lastObject];
        
        NSURL *vacationDataURL = [documentURL URLByAppendingPathComponent:vacationName];
        
        //NSError *error;
        
        vacationDocument = [[UIManagedDocument alloc] initWithFileURL:vacationDataURL];
        [vacationDocuments setValue:vacationDocument forKey:vacationName ];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[vacationDataURL path]])
        {
            // does not exist on disk, so create it
            [VacationHelper getVacationForName:vacationName context:vacationDocument.managedObjectContext];
            
            //and save to storage
            [vacationDocument saveToURL:vacationDataURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                completionBlock(vacationDocument);
            }];
        }
    }
    
    if (vacationDocument.documentState == UIDocumentStateClosed)
    {
        // exists on disk, but we need to open it
        [vacationDocument openWithCompletionHandler:^(BOOL success) {
            [VacationHelper getVacationForName:vacationName context:vacationDocument.managedObjectContext];
            
            completionBlock(vacationDocument);
        }];
    }
    else if (vacationDocument.documentState == UIDocumentStateNormal)
    {
        [VacationHelper getVacationForName:vacationName context:vacationDocument.managedObjectContext];
        completionBlock(vacationDocument);
    }
}

@end