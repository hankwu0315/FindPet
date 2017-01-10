     //
//  NearPetTableViewController.m
//  FindPet
//
//  Created by user51 on 2016/11/24.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import "NearPetTableViewController.h"
#import "SWRevealViewController.h"
#import "ImageOperation.h"
#import "NearPetTableViewCell.h"
#import "Pet.h"
#import "PetViewController.h"
//#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface NearPetTableViewController ()<CLLocationManagerDelegate>

@property(nonatomic) NSMutableArray *findPetData;
@property(nonatomic) NSOperationQueue *queue;

@end

@implementation NearPetTableViewController
{
//    UIImage *cellImage;
    
    CLLocationManager *locationManager;
    
    CLLocation *currentLocation;
    
    double petDistance;
    
    NSString *petDistanceString;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.queue = [[NSOperationQueue alloc]init];
        [self.queue setMaxConcurrentOperationCount:1];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self query];
    self.title = @"附近遺失毛小孩";

    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    self.navigationController.navigationItem.leftBarButtonItem.tintColor = [UIColor brownColor];
    
    //建立CLLocationManger，
    //並存於locationManager實體變數中
    locationManager = [[CLLocationManager alloc] init];
    
    // Ask user's permission 取得user授權
    [locationManager requestWhenInUseAuthorization]; //只有使用App時才能取的位置
    
    //委派予self
    locationManager.delegate = self;
    
    //傳送startUpdatingLocation訊息，
    //開始更新訊息
    [locationManager startUpdatingLocation];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.findPetData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"finpPetCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NearPetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    NSDictionary *item = self.findPetData[indexPath.row];
//    cell.textLabel.text = item[@"breed"];
//    cell.detailTextLabel.text = item[@"size"];
    cell.breedLabel.text = item[@"breed"];
    cell.sizeLabel.text = item[@"size"];
    
    
    //第二个坐标
    CLLocation *stopLocation =[[CLLocation alloc] initWithLatitude:[item[@"lat"] doubleValue] longitude:[item[@"lon"] doubleValue]];
    
    petDistance = [self getDistance:stopLocation fromLocationStart:currentLocation];
    petDistanceString = [[NSString alloc]init];
//    if (petDistance>=1000) {
//        petDistanceString = [petDistanceString stringByAppendingString:@"%f km",petDistance];
////        petDistanceString = [NSString stringWithFormat:<#(nonnull NSString *), ...#>]
//    }else{
//        petDistanceString = [petDistanceString stringByAppendingString:@"m"];
//    }
    
    cell.distanceLabel.text = petDistanceString;
    
    // 將資料庫的圖片位置存入imageUrl
    NSURL *imageUrl = [NSURL URLWithString:item[@"imageUrl"]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        // 將Url轉換成NSData
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        UIImage *image = [UIImage imageWithData:imageData];
        UIImage *smallImage = [self thumnailImage:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            NearPetTableViewCell *cell1 = [tableView cellForRowAtIndexPath:indexPath];
            if ( cell1 ){
                cell1.findImageView.image = smallImage;
//                [cell1 setNeedsLayout];
            }
        });
    });
    // NSData轉換成UIImage
//    cellImage = [UIImage imageWithData:imageData];
    
    
    // Configure the cell...
    
    return cell;
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
            self.findPetData = [NSMutableArray arrayWithArray:pets];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    [task resume];

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"點選到%ld筆",indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //取消選擇
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"petView"]) {
        
        PetViewController *petViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        
//        Pet *newPet = self.findPetData[indexPath.row];
        
        NSDictionary *item = self.findPetData[indexPath.row];
        
        
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
    }
}



-(UIImage*)image{
    
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;

    NSDictionary *item = self.findPetData[indexPath.row];

    NSURL *imageUrl = [NSURL URLWithString:item[@"imageUrl"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *image = [UIImage imageWithData:imageData];
    
    return image;
}

-(UIImage*)thumnailImage:(UIImage *)cellImage{
    
    UIImage *image = cellImage;
    if ( !image){   //有原圖才做縮圖
        return nil;
    }
    
    CGSize thumbnailSize = CGSizeMake(100, 100); //設定縮圖大小
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

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{

    currentLocation = [locations lastObject];
//    CLLocationCoordinate2D coor = currentLocation.coordinate;
//    lat = [[NSString alloc] initWithFormat:@"%f", coor.latitude] ;
//    lon = [[NSString alloc] initWithFormat:@"%f", coor.longitude];
    
    //[self.locationManager stopUpdatingLocation];
}

-(double)getDistance :(CLLocation*)locationStop  fromLocationStart:(CLLocation*)myLocation{
    
    // 计算距离
    CLLocationDistance petsDistance=[locationStop distanceFromLocation:myLocation];
    return petsDistance;
}


-(void)viewWillAppear:(BOOL)animated{
//    [self query];
}

-(void)viewDidAppear:(BOOL)animated{
    [self query];
}
@end
