//
//  VacationTableViewController.h
//  Flickster
//
//  Created by Christopher Snyder on 8/13/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vacation.h"

@interface VacationTableViewController : UITableViewController
@property (nonatomic, strong) Vacation *vacation;
@end
