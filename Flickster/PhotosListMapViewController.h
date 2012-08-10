//
//  PhotoListMapViewController.h
//  Flickster
//
//  Created by Christopher Snyder on 8/9/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import "ListMapViewController.h"

@interface PhotosListMapViewController : ListMapViewController <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>
@property (nonatomic, strong) NSDictionary*place;
@end
