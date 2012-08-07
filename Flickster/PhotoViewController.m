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

@interface PhotoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *photoTitle;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation PhotoViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photoTitle = _photoTitle;
@synthesize toolbar = _toolbar;
@synthesize photo = _photo;

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

-(void) loadImage
{
    if (self.imageView == nil)
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
        
        NSURL *url = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge ];
        
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        
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


-(void) setPhoto:(NSDictionary *)photo
{
    if(_photo!=photo)
    {
        _photo = photo;
        
        //set title
        NSString *title = [photo objectForKey:FLICKR_PHOTO_TITLE];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *description = [photo objectForKey:FLICKR_PHOTO_DESCRIPTION];
        
        if (title.length == 0)
        {
            title = description;
            description = @"";
        }
        
        if (title.length==0 && description.length ==0)
        {
            title = @"Unknown";
        }
        
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
                
                if ([[recentlyViewed objectAtIndex:i] objectForKey:FLICKR_PHOTO_ID] == [photo objectForKey:FLICKR_PHOTO_ID])
                {
                    [recentlyViewed removeObjectAtIndex:i];
                }
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
