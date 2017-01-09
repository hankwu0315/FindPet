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
#import "PetViewController.h"
#import "PetPointAnnotation.h"

@interface MapViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>
{
    CLLocationManager *locationManager;
    NSMutableArray *findPetData;
    
    int notationTag;
    
    UIImage *annotationImage;
    //宣告一個陣列來存放標籤
    NSMutableArray *annotations;
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
    
    notationTag = 0;
    
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
        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);   //地圖縮放大小(經緯度)
        MKCoordinateRegion region = MKCoordinateRegionMake(currentLocation.coordinate, span);
        [_mainMapView setRegion:region animated:true];
        
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
    
    
    annotations = [[NSMutableArray alloc] init];
    
    NSDictionary *item = [NSDictionary new];
    NSLog(@"FIND%lu",(unsigned long)[findPetData count]);
    
    
    
    for (int i = 0; i < [findPetData count]; i++) {
        
        item = findPetData[i];
        
        //隨機設定標籤的緯度
        CLLocationCoordinate2D pinCenter;
        pinCenter.latitude = [item[@"lat"] doubleValue];
        pinCenter.longitude = [item[@"lon"] doubleValue];
        NSLog(@"LAT:%f",pinCenter.latitude);
        NSLog(@"LON:%f",pinCenter.longitude);
        
        //建立一個地圖標籤並設定內文
        MKPointAnnotation *annotation = [MKPointAnnotation new];
        PetPointAnnotation *petAnnotation = [PetPointAnnotation new];
        petAnnotation.coordinate=pinCenter;
        petAnnotation.title = item[@"breed"];
        petAnnotation.subtitle = item[@"size"];
        petAnnotation.sizeLabelText = item[@"size"];
        petAnnotation.index = i;
        
        annotation.coordinate = pinCenter;
        annotation.title = item[@"breed"];
        annotation.subtitle = item[@"size"];
        
        //將製作好的標籤放入陣列中
        [annotations addObject:petAnnotation];
        
    }
    
    //將陣列中所有的標籤顯示在地圖上
    [_mainMapView addAnnotations:annotations];
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    // If it's the user location, just return nil.
    if (annotation == mapView.userLocation) {
        return nil;
    }
;
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]]){
        
        NSString *reuseID = @"pets";
        
        // Try to dequeue an existing pin view first.
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseID];
        
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseID];
            pinView.canShowCallout = YES;    //出現泡泡
//            pinView.image = [UIImage imageNamed:@"petsLocation64.png"];
//            pinView.calloutOffset = CGPointMake(0, 32);
            pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            //RightCallouttAccessoryView
//            UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//            [button addTarget:self action:@selector(calloutButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//            pinView.rightCalloutAccessoryView = button;
            
            pinView.tag = notationTag;
            
            NSDictionary *item = findPetData[pinView.tag];
            
            //LeftCallouttAccessoryView
//            UIImage *image = [UIImage imageNamed:@"petsLocation64.png"];
            NSURL *imageUrl = [NSURL URLWithString:item[@"imageUrl"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
            annotationImage = [UIImage imageWithData:imageData];
            
            // Use our own image as annotation view.
            pinView.image = [self thumnailImage];
            
            pinView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:pinView.image];
            
            
            
        } else {
            pinView.annotation = annotation;
        }
        notationTag++;
        return pinView;

    }
    
    return nil;
}

-(void) calloutButtonTapped:(id)sender {
    //    PetViewController *petViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"petView"];
    //    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //
    //    [self.navigationController pushViewController:petViewController animated:YES];
    //    //    [self presentViewController:petViewController animated:YES completion:nil];
    //    //
    //    //    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    //    //
    //
    //
    //    NSDictionary *item = findPetData;
    //    //
    //    //
    //    petViewController.breedLabelText = item[@"breed"];
    //    petViewController.sizeLabelText = item[@"size"];
    //    petViewController.locationLabelText = item[@"location"];
    //    petViewController.timeLabelText = item[@"UpdateTime"];
    //    petViewController.appearanceTextViewText = item[@"appearance"];
    //    petViewController.lat = item[@"lat"];
    //    petViewController.lon = item[@"lon"];
    //
    //    NSURL *imageUrl = [NSURL URLWithString:item[@"imageUrl"]];
    //    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    //    UIImage *image = [UIImage imageWithData:imageData];
    //
    //    petViewController.petImage = image;
    
    //    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Button Tapped." preferredStyle:UIAlertControllerStyleAlert];
    //    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    //    [alert addAction:ok];
    //    [self  presentViewController:alert animated:true completion:nil];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    PetViewController *petViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"petView"];

    [self.navigationController pushViewController:petViewController animated:YES];

    NSDictionary *item = findPetData[view.tag];
    

    petViewController.breedLabelText = item[@"breed"];
    petViewController.sizeLabelText = item[@"size"];
    petViewController.locationLabelText = item[@"location"];
    petViewController.timeLabelText = item[@"UpdateTime"];
    petViewController.appearanceTextViewText = item[@"appearance"];
    petViewController.lat = item[@"lat"];
    petViewController.lon = item[@"lon"];
    
    NSURL *imageUrl = [NSURL URLWithString:item[@"imageUrl"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *image = [UIImage imageWithData:imageData];
    
    petViewController.petImage = image;
    
    
    notationTag = 0;
}

-(void)viewDidAppear:(BOOL)animated{
    [self query];
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"ok");

}

-(UIImage*)thumnailImage{
    
    UIImage *image = annotationImage;
    if ( !image){   //有原圖才做縮圖
        return nil;
    }
    
    CGSize thumbnailSize = CGSizeMake(20, 20); //設定縮圖大小
    CGFloat scale = [UIScreen mainScreen].scale; //找出目前螢幕的scale，視網膜技術為2.0
    //產生畫布，第一個參數指定大小,第二個參數YES:不透明（黑色底）,false表示透明背景,scale為螢幕scale
    UIGraphicsBeginImageContextWithOptions(thumbnailSize, YES, scale);
    
    //計算長寬要縮圖比例，取最大值MAX會變成UIViewContentModeScaleAspectFill
    //最小值MIN會變成UIViewContentModeScaleAspectFit
    CGFloat widthRatio = thumbnailSize.width / image.size.width;
    CGFloat heightRadio = thumbnailSize.height / image.size.height;
    CGFloat ratio = MAX(widthRatio,heightRadio);
    
    CGSize imageSize = CGSizeMake(image.size.width*ratio, image.size.height*ratio);
    [image drawInRect:CGRectMake(-(imageSize.width-thumbnailSize.width)/2.0, -(imageSize.height-thumbnailSize.height)/2.0,imageSize.width, imageSize.height)];
    
    //取得畫布上的縮圖
    image = UIGraphicsGetImageFromCurrentImageContext();
    //關掉畫布
    UIGraphicsEndImageContext();
    return image;
    
    
    
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
