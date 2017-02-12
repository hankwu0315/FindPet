//
//  MemberViewController.m
//  FindPet
//
//  Created by 吳重漢 on 2017/1/15.
//  Copyright © 2017年 ChungHan Wu. All rights reserved.
//

#import "MemberViewController.h"
#import "SWRevealViewController.h"
#import "StartViewController.h"
#import "MemberPetTableViewCell.h"
#import "PetViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface MemberViewController ()<UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *petTableView;
@property(nonatomic) NSOperationQueue *queue;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageVIew;

@end

@implementation MemberViewController{
    NSUserDefaults *userDefaults;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSMutableArray *findPetData;
    NSMutableArray *sortedPetArray;
    double petDistance;
    NSString *petDistanceString;
    NSMutableDictionary *items;
    NSMutableArray *distanceArray;
    NSString *accountStr;
    BOOL reloadCtr;
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
    
    self.title = @"個人資料";
    
    
    //leftSideBarButton
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
    //leftSideBarButton顏色
//    self.sidebarButton.tintColor =[UIColor colorWithRed:1/255.0 green:209/255.0 blue:110/255.0 alpha:1];
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
    UIImage *backgroundImage = [UIImage imageNamed:@"back6.jpg"];
    UIImageView *backgroundImageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundImageView.image=backgroundImage;
    [self.view insertSubview:backgroundImageView atIndex:0];
    
    self.petTableView.backgroundColor = [UIColor clearColor];
    
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
    
    self.petTableView.delegate = self;
    self.petTableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logOutBarBtn:(UIBarButtonItem *)sender {
    [userDefaults removeObjectForKey:@"userID"];
    [findPetData removeAllObjects];
    [sortedPetArray removeAllObjects];
    
//    [self.navigationController popViewControllerAnimated:YES];

    [self dismissViewControllerAnimated:YES completion:nil];
    StartViewController *startViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"startNC"];
    [self presentViewController:startViewController animated:YES completion:nil];
}


#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return findPetData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"memberPetCell";
    MemberPetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *item;
    item = findPetData[indexPath.row];
//    if (findPetData.count == 1) {
//        item = findPetData[indexPath.row];
//    }else{
//        item = sortedPetArray[indexPath.row];
//    }
    cell.breedLabel.text = item[@"breed"];
    
    cell.sizeLabel.text = item[@"size"];
    cell.sizeLabel.textColor = [UIColor colorWithRed:143/255.0 green:85/255.0 blue:30/255.0 alpha:1];
//    petDistance = [item[@"distance"] doubleValue];
//    
//    if (petDistance >= 1000) {
//        petDistanceString = [NSString stringWithFormat:@"%.2f km",petDistance/1000];
//    }else{
//        petDistanceString = [NSString stringWithFormat:@"%.2f m",petDistance];
//    }
//    
//    cell.distanceLabel.text = petDistanceString;
    cell.distanceLabel.text = item[@"UpdateTime"];
    cell.distanceLabel.textColor = [UIColor colorWithRed:143/255.0 green:85/255.0 blue:30/255.0 alpha:1];
    
    // 將資料庫的圖片位置存入imageUrl
    NSURL *imageUrl = [NSURL URLWithString:item[@"imageUrl"]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        // 將Url轉換成NSData
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        UIImage *image = [UIImage imageWithData:imageData];
        UIImage *smallImage = [self thumnailImage:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            MemberPetTableViewCell *cell1 = [tableView cellForRowAtIndexPath:indexPath];
            if ( cell1 ){
                cell1.findImageView.image = smallImage;
                //設定圓角半徑，設定cornerRadius來更改
                cell1.findImageView.layer.cornerRadius = cell1.findImageView.frame.size.width / 2;
                //圓角半徑,預設為零 ; 如果更改就會畫角 ; 要改成圓的話，設定該View寬/2即可。
            }
        });
    });
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return @"Delete";
//}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self deleteCell:indexPath];
        [self sendAccountInfo];
        [findPetData removeObjectAtIndex:indexPath.row];
        [tableView endUpdates];
        [self.petTableView reloadData];
    }
    
//    [self.petTableView reloadData];
}

-(void)deleteCell:(NSIndexPath *)indexPath{
    
    NSDictionary *item = findPetData[indexPath.row];
//    NSDictionary *item = sortedPetArray[indexPath.row];
    
    NSURL *url = [NSURL URLWithString:@"https://codomo.000webhostapp.com/memberDeletePetmenus_json.php"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    //POST
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *params = [NSString stringWithFormat:@"UpdateTime=%@&userID=%@",
                        item[@"UpdateTime"],accountStr];
    NSLog(@"%@",params);
    NSData *body = [params dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:body];
    NSLog(@"%@",request);
    
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ( error ){
            NSLog(@"error %@",error);
        }else{
            NSString *status = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"status = %@",status);
            //自己要檢查是否有錯誤回傳

            [locationManager startUpdatingLocation];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.petTableView reloadData];
            });
        }
        
    }];
    [task resume];
    [self.petTableView reloadData];
}

-(void)sendAccountInfo{
    
    NSURL *url = [NSURL URLWithString:@"https://codomo.000webhostapp.com/memberpetmenus_json.php"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    //POST
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *params = [NSString stringWithFormat:@"userID=%@",
                        accountStr];
    NSLog(@"%@",params);
    NSData *body = [params dataUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPBody:body];
    NSLog(@"%@",request);

    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ( error ){
            NSLog(@"error %@",error);
        }else{
            NSString *status = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"status = %@",status);
            //自己要檢查是否有錯誤回傳
            findPetData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
//            NSDictionary *item = findPetData[0];
//            NSLog(@"breed=%@,size=%@,location=%@,appearance=%@,UpdateTime=%@,displayTime=%@,imageUrl=%@",item[@"breed"],item[@"size"],item[@"location"],item[@"appearance"],item[@"UpdateTime"],item[@"displayTime"],item[@"imageUrl"]);
            [locationManager startUpdatingLocation];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.petTableView reloadData];
            });
        }
        
    }];
    [task resume];
//    [self.petTableView reloadData];
    
}


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
    
//    [self sortDistance];//先關閉距離排序

}


-(double)getDistance :(CLLocation*)locationStop  fromLocationStart:(CLLocation*)myLocation{
    // 計算距離
    CLLocationDistance petsDistance=[locationStop distanceFromLocation:myLocation];
    return petsDistance;
}

-(void)sortDistance{
    for (int i = 0 ; i < findPetData.count ; i++) {
        items = findPetData[i];
        CLLocation *stopLocation =[[CLLocation alloc] initWithLatitude:[items[@"lat"] doubleValue] longitude:[items[@"lon"] doubleValue]];
        NSString *distance = [NSString stringWithFormat:@"%f",[self getDistance:stopLocation fromLocationStart:currentLocation]];
        [distanceArray addObject:distance];
        
        if (i == 0 && findPetData.count == 1) {
//            NSMutableDictionary *item = findPetData[0];
//            double dist;
//            CLLocation *itemLocation =[[CLLocation alloc] initWithLatitude:[item[@"lat"] doubleValue] longitude:[item[@"lon"] doubleValue]];
//            dist = [self getDistance:itemLocation fromLocationStart:currentLocation];
            items[@"distance"] = distanceArray[0];
//            sortedPetArray = [findPetData mutableCopy];
            findPetData = [findPetData mutableCopy];
        }
    }
    
    //根據距離做排序
    
//    sortedPetArray =  [[findPetData sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {

    findPetData =  [[findPetData sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
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
//    if ([[userDefaults objectForKey:@"reloadCtr"] description]) {
//        [self.petTableView reloadData];
//        [userDefaults setBool:NO forKey:@"reloadCtr"];
//    }
    if (reloadCtr) {
        [self.petTableView reloadData];
        reloadCtr = NO;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"mamberPetView"]) {
        
        PetViewController *petViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = self.petTableView.indexPathForSelectedRow;
        
//        NSDictionary *item = sortedPetArray[indexPath.row];
        NSDictionary *item = findPetData[indexPath.row];
        
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


-(void)viewWillAppear:(BOOL)animated{

    //    [userDefaults setBool:YES forKey:@"reloadCtr"];
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    accountStr = [[userDefaults objectForKey:@"userID"] description];
    self.accountLabel.text = @"";
    self.accountLabel.text = accountStr;
    
    
    //rightSideBarButton
    if ([[[userDefaults dictionaryRepresentation] allKeys] containsObject:@"userID"]) {
        self.logOutBtn.title = @"登出";
    } else {
        self.logOutBtn.title = @"登入";
    }
    
    reloadCtr = YES;
    [self sendAccountInfo];
}


@end
