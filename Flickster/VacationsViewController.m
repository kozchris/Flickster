//
//  VacationsViewController.m
//  Flickster
//
//  Created by Christopher Snyder on 8/12/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "VacationsViewController.h"
#import "VacationHelper.h"
#import "Common.h"
#import "VacationTableViewController.h"
#import "Vacation.h"

@interface VacationsViewController ()
@property (nonatomic, strong) NSArray *vacations;
@end

@implementation VacationsViewController
@synthesize toolbar = _toolbar;
@synthesize tableView = _tableView;
@synthesize vacations = _vacations;

-(void) setVacations:(NSArray *)vacations
{
    if(_vacations != vacations)
    {
        _vacations = vacations;
        [self.tableView reloadData];
    }
}

-(void) loadVacations
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
    self.toolbar.items = toolbarItems;
    
    dispatch_queue_t loadVacations = dispatch_queue_create("load vacations", NULL);
    dispatch_async(loadVacations, ^{
        
        //check for vacation files in documents directory
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSURL *documentURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask ] lastObject];
        
        NSError *error;
        
        NSArray *propertyKeys = [[NSArray alloc] initWithObjects:NSURLCreationDateKey, NSURLNameKey, NSURLContentAccessDateKey, NSURLFileSizeKey, nil];
        NSArray *vacationFiles = [fileManager contentsOfDirectoryAtURL:documentURL includingPropertiesForKeys:propertyKeys options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
        
        NSArray *vacationFilesByAccessDateDesc;
        
        if (vacationFiles.count > 0)
        {
            //order the vacation files by last accessed descending
            vacationFilesByAccessDateDesc = [vacationFiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                                                  {
                                                      NSURL *file1 = obj1;
                                                      NSURL *file2 = obj2;
                                                      
                                                      NSDate *file1ModificationDate, *file2ModificationDate;
                                                      NSError *error;
                                                      [file1 getResourceValue:&file1ModificationDate forKey:NSURLContentAccessDateKey error:&error];
                                                      [file2 getResourceValue:&file2ModificationDate forKey:NSURLContentAccessDateKey error:&error];
                                                      
                                                      NSComparisonResult result = NSOrderedSame;
                                                      if (file1ModificationDate > file2ModificationDate)
                                                      {
                                                          result = NSOrderedDescending;
                                                      }
                                                      else if (file1ModificationDate < file2ModificationDate)
                                                      {
                                                          result = NSOrderedAscending;
                                                      }
                                                      
                                                      return result;
                                                  }];
            
        }
        else
        {
            NSURL * defaultVacation = [documentURL URLByAppendingPathComponent:DEFAULT_VACATION];
            vacationFilesByAccessDateDesc = [[NSArray alloc] initWithObjects:defaultVacation, nil];
            /*
             //no vacation file exists, create the default
            [VacationHelper openVacation:@"My Vacation" usingBlock:^(UIManagedDocument*vacation){
                dispatch_async(dispatch_get_main_queue(), ^{
                self.vacations = [[NSArray alloc] initWithObjects:vacation];
                
                NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
                [toolbarItems removeLastObject];
                self.toolbar.items = toolbarItems;
            });
             }];
           */
            //init with My Vacation
            //create default vacation file
            //save
            //update vacation list
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.vacations = vacationFilesByAccessDateDesc;
            
            NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
            [toolbarItems removeLastObject];
            self.toolbar.items = toolbarItems;
        });
        
        
    });
    dispatch_release(loadVacations);
}

#pragma table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.vacations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Vacation Table Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSURL *vacationURL = [self.vacations objectAtIndex:indexPath.row];
    cell.textLabel.text = [vacationURL lastPathComponent];
    
    return cell;
}

#pragma viewcontroller

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Vacation Selection"] )
    {
        VacationTableViewController *vacationTableViewController = segue.destinationViewController;
        NSString *vacationName = ((UITableViewCell *)sender).textLabel.text;
        
        [VacationHelper openVacation:vacationName usingBlock:^(UIManagedDocument *vacationDocument)
        {
            Vacation *vacation = nil;
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Vacation"];
            request.predicate = [NSPredicate predicateWithFormat:@"name = %@", vacationName];
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
            request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
            NSError *error = nil;
            NSArray *matches = [vacationDocument.managedObjectContext executeFetchRequest:request error:&error];
            
            vacation = [matches lastObject];
            
            vacationTableViewController.vacation = vacation;
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self loadVacations];
}

- (void)viewDidUnload
{
    [self setToolbar:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
