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
    NSMutableArray *findPetData;
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
    self.mainMapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    self.mainMapView.delegate = self;
    
    [self query];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *currentLocation = locations.lastObject;
    NSLog(@"Current Location: %.6f,%.6f (H.Accury: %f)",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude,currentLocation.horizontalAccuracy);
    
    static dispatch_once_t moveMapOnceToken = 0;    //dispatch_once在整個生命週期只run一次
    dispatch_once(&moveMapOnceToken, ^{
//        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);   //地圖縮放大小(經緯度)
//        MKCoordinateRegion region = MKCoordinateRegionMake(currentLocation.coordinate, span);
//        [_mainMapView setRegion:region animated:true];
        
        // Add Annotation
        CLLocationCoordinate2D myCoordinate = currentLocation.coordinate;
      
        MKPointAnnotation *annotation = [MKPointAnnotation new];
        annotation.coordinate = myCoordinate;


    });
    
    
}


-(void)query{
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:8888/petmenus_json.php"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ( error ){
            
            //            show alertcontroller
            
        }else{
            
            //                    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //                    NSLog(@"json = %@",content);
            NSError *error = nil;
            NSArray *pets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            //
            NSDictionary *item = pets[0];
            NSLog(@"breed=%@,size=%@,location=%@,appearance=%@,UpdateTime=%@,displayTime=%@,imageUrl=%@",item[@"breed"],item[@"size"],item[@"location"],item[@"appearance"],item[@"UpdateTime"],item[@"displayTime"],item[@"imageUrl"]);
            findPetData = [NSMutableArray arrayWithArray:pets];
        }
    }];
    [task resume];
    [self setViewMapPin];
    
}

- (void)setViewMapPin {
    
    //宣告一個陣列來存放標籤
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (int i = 1; i <= 10; i++) {
        
        //隨機設定標籤的緯度
        CLLocationCoordinate2D pinCenter;
        pinCenter.latitude = 24.9 + (float)(arc4random() % 100) / 1000;
        pinCenter.longitude = 121.5 + (float)(arc4random() % 100) / 1000;
        
        //建立一個地圖標籤並設定內文
//        PlacePin *annotation = [[PlacePin alloc]initWithCoordinate:pinCenter];
        MKPointAnnotation *annotation = [MKPointAnnotation new];
        annotation.coordinate = pinCenter;

        
        //將製作好的標籤放入陣列中
        [annotations addObject:annotation];

    }
    
    //將陣列中所有的標籤顯示在地圖上
    [_mainMapView addAnnotations:annotations];
    
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
