//
//  PhotoViewController.h
//  Flickster
//
//  Created by Christopher Snyder on 8/5/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface PhotoViewController : UIViewController <UISplitViewControllerDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) NSDictionary *photo;
@property (nonatomic, strong) Photo *itineraryPhoto;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *visitUnVisitClick;
@end
