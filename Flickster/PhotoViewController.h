//
//  PhotoViewController.h
//  Flickster
//
//  Created by Christopher Snyder on 8/5/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController <UISplitViewControllerDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) NSDictionary *photo;
@end
