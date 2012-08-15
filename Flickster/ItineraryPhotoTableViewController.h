//
//  ItineraryPhotoTableViewController.h
//  Flickster
//
//  Created by Christopher Snyder on 8/13/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Itinerary.h"
#import "Tag.h"

@interface ItineraryPhotoTableViewController : CoreDataTableViewController
@property (nonatomic, strong) Itinerary *itinerary;
@property (nonatomic, strong) Tag *tag;
@end
