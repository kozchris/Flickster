//
//  ListMapViewController.h
//  Flickster
//
//  Created by Christopher Snyder on 8/8/12.
//  Copyright (c) 2012 Christopher Snyder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ListMapViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>
@property (nonatomic, strong) NSArray *annotations;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

//return the array of FlickerPhotoAnnotations of FlickerPlaceAnnotations
-(NSArray*)getAnnotations;

//refresh the data used
-(void)refreshData;

- (IBAction)listMapClick:(UISegmentedControl *)sender;

- (IBAction)refreshClick:(UIBarButtonItem *)sender;
@end
