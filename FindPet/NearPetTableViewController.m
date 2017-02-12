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
#import "PetViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MBProgressHUD.h>

@interface NearPetTableViewController ()<CLLocationManagerDelegate>

//@property(nonatomic) NSMutableArray *findPetData;
@property(nonatomic) NSOperationQueue *queue;

@end

@implementation NearPetTableViewController
{
    //    UIImage *cellImage;
    //    NSArray *findPetData;
    //    NSMutableArray *addDisfindPetData;
    
    NSMutableArray *findPetData;
    
    NSMutableArray *sortedPetArray;
    
    CLLocationManager *locationManager;
    
    CLLocation *currentLocation;
    
    double petDistance;
    
    NSString *petDistanceString;
    
    NSMutableDictionary *items;
    NSMutableArray *distanceArray;
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

    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    //sideBar顏色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:237/255.0 green:209/255.0 blue:110/255.0 alpha:1];
    
    //消除Back文字
    UIBarButtonItem *barbtnItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:barbtnItem];
    
    //Bar顏色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:71/255.0 green:163/255.0 blue:1 alpha:1];
    
    //Title顏色
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    //加入背景圖
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back2.png"]];
    
    items = [NSMutableDictionary dictionary];
    distanceArray = [NSMutableArray array];
    //建立CLLocationManger，
    //並存於locationManager實體變數中
    locationManager = [[CLLocationManager alloc] init];
    
    // Ask user's permission 取得user授權
    [locationManager requestWhenInUseAuthorization]; //只有使用App時才能取的位置
    
    //委派予self
    locationManager.delegate = self;
    
    //傳送startUpdatingLocation訊息
    //開始更新訊息
    [locationManager startUpdatingLocation];
    
}

#pragma mark UISet 狀態列改白色文字
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
    return findPetData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"finpPetCell";
    NearPetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // teacher modified the next one line of code
    //    NSDictionary *item = findPetData[indexPath.row];
    //    NSMutableDictionary *item = [findPetData[indexPath.row] mutableCopy];
    NSDictionary *item = sortedPetArray[indexPath.row];
    
    
    cell.breedLabel.text = item[@"breed"];
//    cell.breedLabel.textColor = [UIColor colorWithRed:237/255.0 green:209/255.0 blue:110/255.0 alpha:1];
    cell.sizeLabel.text = item[@"size"];
    cell.sizeLabel.textColor = [UIColor colorWithRed:143/255.0 green:85/255.0 blue:30/255.0 alpha:1];
    petDistance = [item[@"distance"] doubleValue];
    
    if (petDistance >= 1000) {
        petDistanceString = [NSString stringWithFormat:@"%.2f km",petDistance/1000];
    }else{
        petDistanceString = [NSString stringWithFormat:@"%.2f m",petDistance];
    }
    
    
    cell.distanceLabel.text = petDistanceString;
    cell.distanceLabel.textColor = [UIColor colorWithRed:69/255.0 green:65/255.0 blue:2/255.0 alpha:1];
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
                //設定圓角半徑，設定cornerRadius來更改
                cell1.findImageView.layer.cornerRadius = cell1.findImageView.frame.size.width / 2;
                //圓角半徑,預設為零 ; 如果更改就會畫角 ; 要改成圓的話，設定該View寬/2即可。
                
                //                [cell1 setNeedsLayout];
            }
        });
    });
    
    // Configure the cell...
    //毛玻璃效果
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
//    cell.backgroundView = blurEffectView;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


-(void)query{
    
    NSURL *url = [NSURL URLWithString:@"https://codomo.000webhostapp.com/petmenus_json.php"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ( error ){
            
            //            show alertcontroller
            
        }else{
            
            //                    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //                    NSLog(@"json = %@",content);
            NSError *error = nil;
            //            NSArray *pets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            findPetData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            NSDictionary *item = findPetData[0];
            NSLog(@"breed=%@,size=%@,location=%@,appearance=%@,UpdateTime=%@,displayTime=%@,imageUrl=%@",item[@"breed"],item[@"size"],item[@"location"],item[@"appearance"],item[@"UpdateTime"],item[@"displayTime"],item[@"imageUrl"]);
            
//            NSDictionary *items = [NSDictionary dictionary];
//            NSMutableArray *distanceArray = [NSMutableArray array];
            
            
            [locationManager startUpdatingLocation];
//            while (!currentLocation) {
//                NSArray *locations = [NSArray array];
//                [self locationManager:locationManager didUpdateLocations:locations];
//            }
            
            
            
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
        
        NSDictionary *item = sortedPetArray[indexPath.row];
        
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



//-(UIImage*)image{
//    
//    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
//    
//    NSDictionary *item = sortedPetArray[indexPath.row];
//    
//    NSURL *imageUrl = [NSURL URLWithString:item[@"imageUrl"]];
//    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
//    UIImage *image = [UIImage imageWithData:imageData];
//    
//    return image;
//}


-(UIImage*)thumnailImage:(UIImage *)cellImage{
    
    //    UIImage *image = cellImage;
    if ( !cellImage){   //有原圖才做縮圖
        return nil;
    }
    
    CGSize thumbnailSize = CGSizeMake(100, 100); //設定縮圖大小
    CGFloat scale = [UIScreen mainScreen].scale; //找出目前螢幕的scale，視網膜技術為2.0
    //產生畫布，第一個參數指定大小,第二個參數YES:不透明（黑色底）,false表示透明背景,scale為螢幕scale
    UIGraphicsBeginImageContextWithOptions(thumbnailSize, YES, scale);
    
    //計算長寬要縮圖比例，取最大值MAX會變成UIViewContentModeScaleAspectFill
    //最小值MIN會變成UIViewContentModeScaleAspectFit
    CGFloat widthRatio = thumbnailSize.width / cellImage.size.width;
    CGFloat heightRadio = thumbnailSize.height / cellImage.size.height;
    CGFloat ratio = MAX(widthRatio,heightRadio);
    
    CGSize imageSize = CGSizeMake(cellImage.size.width*ratio, cellImage.size.height*ratio);
    [cellImage drawInRect:CGRectMake(-(imageSize.width-thumbnailSize.width)/2.0, -(imageSize.height-thumbnailSize.height)/2.0,imageSize.width, imageSize.height)];
    
    //取得畫布上的縮圖
    cellImage = UIGraphicsGetImageFromCurrentImageContext();
    //關掉畫布
    UIGraphicsEndImageContext();
    return cellImage;
    
}

#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    currentLocation = [locations lastObject];
    //    CLLocationCoordinate2D coor = currentLocation.coordinate;
    //    lat = [[NSString alloc] initWithFormat:@"%f", coor.latitude] ;
    //    lon = [[NSString alloc] initWithFormat:@"%f", coor.longitude];
    
    //[self.locationManager stopUpdatingLocation];
    

    for (int i = 0 ; i < findPetData.count ; i++) {
        items = findPetData[i];
        CLLocation *stopLocation =[[CLLocation alloc] initWithLatitude:[items[@"lat"] doubleValue] longitude:[items[@"lon"] doubleValue]];
        NSString *distance = [NSString stringWithFormat:@"%f",[self getDistance:stopLocation fromLocationStart:currentLocation]];
        [distanceArray addObject:distance];
        
        //如果TableView只有一筆,不做距離排序
        if (i == 0 && findPetData.count == 1) {
            items[@"distance"] = distanceArray[0];
            sortedPetArray = [findPetData mutableCopy];
        }
    }
    NSLog(@"CURRENTLOCATION : %@",currentLocation);
    
    //根據距離做排序
    sortedPetArray =  [[findPetData sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSMutableDictionary *item1 = obj1;
        NSMutableDictionary *item2 = obj2;
        double dist1;
        double dist2;
        
        if (item1[@"distance"]) {
            dist1 = [item1[@"distance"] doubleValue];
        } else {
            CLLocation *item1Location =[[CLLocation alloc] initWithLatitude:[item1[@"lat"] doubleValue] longitude:[item1[@"lon"] doubleValue]];
            dist1 = [self getDistance:item1Location fromLocationStart:currentLocation];
            item1[@"distance"] = @(dist1);
        }
        
        if (item2[@"distance"]) {
            dist2 = [item2[@"distance"] doubleValue];
        } else {
            CLLocation *item2Location =[[CLLocation alloc] initWithLatitude:[item2[@"lat"] doubleValue] longitude:[item2[@"lon"] doubleValue]];
            dist2 = [self getDistance:item2Location fromLocationStart:currentLocation];
            item2[@"distance"] = @(dist2);
        }
        return (dist1 < dist2) ? -1 : 1;
    }] mutableCopy];
    
    [self.tableView reloadData];
}

-(double)getDistance :(CLLocation*)locationStop  fromLocationStart:(CLLocation*)myLocation{
    // 計算距離
    CLLocationDistance petsDistance=[locationStop distanceFromLocation:myLocation];
    return petsDistance;
}


-(void)viewDidAppear:(BOOL)animated{
    
    [self query];
}
@end
