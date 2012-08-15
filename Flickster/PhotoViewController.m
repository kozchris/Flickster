//
//  PhotoViewController.m
//  Flickster
//
//  Created by Christopher Snyder on 8/5/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"
#import "Common.h"
#import "Vacation.h"
#import "Photo.h"
#import "Itinerary.h"
#import "VacationHelper.h"
#import "Itinerary+create.h"
#import "Photo+create.h"
#import "Tag+create.h"

@interface PhotoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *photoTitle;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) Vacation *vacation;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *visitButton;
@property (nonatomic, strong) NSString *photoId;
@end

@implementation PhotoViewController
@synthesize visitButton = _visitButton;
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photoTitle = _photoTitle;
@synthesize toolbar = _toolbar;
@synthesize photo = _photo;
@synthesize itineraryPhoto = _itineraryPhoto;
@synthesize visitUnVisitClick = _visitUnVisitClick;
@synthesize photoId = _photoId;

-(void)setPhotoId:(NSString *)photoId
{
    if(![_photoId isEqualToString:photoId])
    {
        _photoId = photoId;
        Photo *photo = [self getVacationPhoto];
        [self setPhotoForId:self.photoId title:photo.title subTitle:photo.subtitle];
    }
}

-(void)setItineraryPhoto:(Photo *)itineraryPhoto
{
    if (_itineraryPhoto != itineraryPhoto)
    {
        _itineraryPhoto = itineraryPhoto;
        self.photoId = itineraryPhoto.photoId;
    }
}

-(void) setPhoto:(NSDictionary *)photo
{
    if(_photo!=photo)
    {
        _photo = photo;
        
        self.photoId = [self.photo objectForKey:FLICKR_PHOTO_ID];
        
        //set title
        NSString *title = [photo objectForKey:FLICKR_PHOTO_TITLE];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *description = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        
        if (title.length == 0)
        {
            title = description;
            description = @"";
        }
        
        if (title.length==0 && description.length ==0)
        {
            title = @"Unknown";
        }
        
        [self setPhotoForId:self.photoId title:title subTitle:description];
    }
}

-(Photo*) getVacationPhoto
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photoId = %@", self.photoId];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [self.vacation.managedObjectContext executeFetchRequest:request error:&error];
    Photo *vacationPhoto;
    if (matches.count==1)
    {
        vacationPhoto = [matches lastObject];
    }
    return vacationPhoto;
}

-(Itinerary *) itineraryForName:(NSString*)name
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Itinerary"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [self.vacation.managedObjectContext executeFetchRequest:request error:&error];
    Itinerary *itinerary;
    if (matches.count==1)
    {
        itinerary = [matches lastObject];
    }
    return itinerary;
}

-(void) setVisitUnVisitButton
{
    //see if photo is in db
    Photo *vacationPhoto = [self getVacationPhoto];
    
    self.visitButton.title = (vacationPhoto!=nil)?@"UnVisit" : @"Visit";
}

-(void)setVacation:(Vacation *)vacation
{
    if(_vacation!=vacation)
    {
        _vacation = vacation;
        [self setVisitUnVisitButton];
    }
}

-(void) getCurrentVacation
{
    NSString *vacationName = DEFAULT_VACATION;
    
    [VacationHelper openVacation:DEFAULT_VACATION usingBlock:^(UIManagedDocument *vacationDocument){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Vacation"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", vacationName];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        NSError *error = nil;
        NSArray *matches = [vacationDocument.managedObjectContext executeFetchRequest:request error:&error];
        
        self.vacation = [matches lastObject];
    }];
}

-(void) setupScrollView
{
    CGFloat hScale, wScale, scale;
    
    hScale = self.scrollView.bounds.size.height/self.imageView.image.size.height;
    wScale = self.scrollView.bounds.size.width/self.imageView.image.size.width;
    
    scale  = (hScale > wScale)? hScale : wScale;
    self.scrollView.contentSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0,0, self.imageView.image.size.width, self.imageView.image.size.height);
    
    self.scrollView.zoomScale = scale;
}

#define MAX_IMAGE_CACHE_SIZE 10000000

-(void) loadImage
{
    if (self.imageView == nil || self.photoId == nil)
    {
        return;
    }
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
    self.toolbar.items = toolbarItems;
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        //check for image in cache
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSURL *cacheURL = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask ] lastObject];
        
        NSError *error;
        
        NSString *imageFileName = [@"img_" stringByAppendingString:self.photoId];
        NSURL *imageURL = [[NSURL alloc] initWithString:imageFileName relativeToURL:cacheURL];
        
        //try to read and check error as described as best practice in documentation instead of using file exists check
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL options:NSDataReadingMappedIfSafe error:&error];
        if (error != nil )
        {
            //not found
            if ([error code] == NSFileReadNoSuchFileError)
            {
                //if not in cache, fetch image
                NSURL *url = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge ];
                imageData = [NSData dataWithContentsOfURL:url];
                
                //reduce cache size if greater than 10MB
                //by removing oldest files
                //get array of files delete oldest file until cache is less than 10MB
                NSArray *propertyKeys = [[NSArray alloc] initWithObjects:NSURLCreationDateKey, NSURLNameKey, NSURLContentAccessDateKey, NSURLFileSizeKey, nil];
                NSArray *cacheFiles = [fileManager contentsOfDirectoryAtURL:cacheURL includingPropertiesForKeys:propertyKeys options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
                
                __block int currentCacheSize = 0;
                [cacheFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                    NSNumber *fileSize;
                    NSError *error;
                    [(NSURL*)obj getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error];
                    if (error!=nil)
                    {
                        *stop = YES;
                    }
                    currentCacheSize += [fileSize intValue];
                }];
                
                if ( currentCacheSize + [imageData length] > MAX_IMAGE_CACHE_SIZE )
                {
                    //order the cache files
                    NSArray *cacheFilesByAccessDateDesc = [cacheFiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
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
                    
                    int spaceNeeded = currentCacheSize + [imageData length] - MAX_IMAGE_CACHE_SIZE;
                    for(NSURL *cacheFile in cacheFilesByAccessDateDesc)
                    {
                        NSNumber *fileSize;
                        [cacheFile getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error];
                        
                        [fileManager removeItemAtURL:cacheFile error:&error];
                        
                        spaceNeeded -= [fileSize intValue];
                        if (spaceNeeded < 0)
                        {
                            break;
                        }
                    }
                }
                
                // and add to cache if size is < 10MB
                if ([imageData length] < MAX_IMAGE_CACHE_SIZE )
                {
                    [imageData writeToURL:imageURL atomically:YES];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            
            //necessary to reset zoom scale so that next time zoom is set new value will get used.
            self.scrollView.zoomScale = 1.0;
            
            self.imageView.image = image;
            
            [self setupScrollView];
            
            NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
            [toolbarItems removeLastObject];
            self.toolbar.items = toolbarItems;
        });
        
    });
    dispatch_release(downloadQueue);
}


-(void) setPhotoForId:(NSString*)photoId title:(NSString*)title subTitle:(NSString *)subTitle
{
    //set title
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    self.title = title;
    self.photoTitle.title = title;
    
    //add image to recently viewed list
    dispatch_queue_t addRecentToDefaults = dispatch_queue_create("add recent to defaults", NULL);
    dispatch_async(addRecentToDefaults, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *recentlyViewed;
        NSArray *keyValue = [defaults valueForKey:KEY_RECENT_PHOTOS];
        if(keyValue==nil)
        {
            recentlyViewed = [[NSMutableArray alloc] init];
        }
        else
        {
            recentlyViewed = [keyValue mutableCopy];
        }
        
        //remove any copies of them image already in list
        for (int i=recentlyViewed.count-1; i>=0; i--) {
            /*
             NSDictionary *test = [recentlyViewed objectAtIndex:i];
             for (NSString *key in test.allKeys) {
             NSLog(@"key: %@ : %@", key, [test objectForKey:key]);
             }*/
            
            if ([[[recentlyViewed objectAtIndex:i] objectForKey:FLICKR_PHOTO_ID] isEqualToString: self.photoId])
            {
                [recentlyViewed removeObjectAtIndex:i];
            }
        }
        
        //make our own stripped down photo dictionary to save in recents array
        NSDictionary *photo = self.photo;
        
        //check photoId to see if we were created from itinerary photo, if so then create photo dictionary
        if (photoId == self.itineraryPhoto.photoId)
        {
            photo = [self.itineraryPhoto FlickrPhotoFromPhoto];
        }
            
        [recentlyViewed insertObject:photo atIndex:0];
        
        if(recentlyViewed.count>MAX_RECENT_PHOTOS)
        {
            [recentlyViewed removeLastObject];
        }
        
        [defaults setValue:recentlyViewed forKey:KEY_RECENT_PHOTOS];
        [defaults synchronize];
    });
    dispatch_release(addRecentToDefaults);
    
    //draw image
    [self loadImage];
}

- (IBAction)visitUnVisitClick:(UIBarButtonItem *)sender {
    //see if photo is in db
    Photo *vacationPhoto = [self getVacationPhoto];
    
    if(vacationPhoto)
    {
        //decrement any tag counts, and remove photo reference
        NSSet *tags = vacationPhoto.tags;
        for (Tag *tag in tags) {
            tag.count = [[NSNumber alloc] initWithInt:[tag.count intValue]-1];
        }
        
        //decrement photo count
        vacationPhoto.itinerary.count = [[NSNumber alloc] initWithInt:[vacationPhoto.itinerary.count intValue]+1];
        //remove photo from itinerary
        [vacationPhoto.itinerary removePhotosObject:vacationPhoto];
        
        sender.title = @"Visit";
    }
    else
    {
        //add photo to itinerary
        NSString *placeName = [self.photo valueForKey:FLICKR_PHOTO_PLACE_NAME];
        Itinerary *itinerary = [self itineraryForName:placeName];
        if (itinerary==nil)
        {
            //add new itineary
            itinerary = [Itinerary itineraryWithTitle:placeName inManagedObjectContext:self.vacation.managedObjectContext];
            [self.vacation addItinerariesObject:itinerary];
        }
        
        //add photo (adds tags also)
        vacationPhoto = [Photo photoInItinerary:itinerary fromPhotoDictionary:self.photo];
        
        sender.title = @"UnVisit";
    }
}

-(void) awakeFromNib
{
    self.splitViewController.delegate = self;
    
    [super awakeFromNib];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getCurrentVacation];
}

-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self setupScrollView];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadImage];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scrollView flashScrollIndicators];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [self setPhotoTitle:nil];
    [self setToolbar:nil];
    [self setVisitUnVisitClick:nil];
    [self setVisitButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Photos";
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems insertObject:barButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)button
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems removeObject:button];
    self.toolbar.items = toolbarItems;
}

@end
