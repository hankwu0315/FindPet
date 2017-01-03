//
//  MapViewController.m
//  FindPet
//
//  Created by user51 on 2016/12/29.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>
{
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [CLLocationManager new];
    
    //取得user授權
    [locationManager requestWhenInUseAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.activityType = CLActivityTypeFitness;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];

    self.mainMapView.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
