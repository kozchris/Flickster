//
//  FlicksterViewController.m
//  Flickster
//
//  Created by Christopher Snyder on 8/6/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "FlicksterViewController.h"

@interface FlicksterViewController ()

@end

@implementation FlicksterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
