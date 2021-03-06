//
//  FoundPetViewController.m
//  FindPet
//
//  Created by user51 on 2016/11/25.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import "FoundPetViewController.h"
#import "SWRevealViewController.h"
#import <AFNetworking.h>
#import <AFURLRequestSerialization.h>
#import "NearPetTableViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface FoundPetViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate,CLLocationManagerDelegate>
{
    NSArray *sizeArray;
    NSString *sizeString;
    
    UIImage *uploadImage;
    NSString *imageUrl;
    
    UIDatePicker *datePicker;
    NSLocale *datelocale;

    CLLocationManager *locationManager;
    
    NSString *lat;
    NSString *lon;
}
@property (weak, nonatomic) IBOutlet UIButton *Camera;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *breedTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *sizePickerView;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UITextView *appearTextView;
@property (nonatomic) UIImage *image;
@property(nonatomic) NSMutableArray *findPetData;


@end

@implementation FoundPetViewController{
    NSUserDefaults *userDefaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    //    [self.Camera setImage:[UIImage imageNamed:@"camera-6.png"] forState:UIControlStateNormal];

    //Title顏色
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    
    //leftSideBarButton
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    //
    sizeArray = [[NSArray alloc] initWithObjects:@"請選擇",@"大",@"中",@"小", nil];
    self.sizePickerView.dataSource = self;
    self.sizePickerView.delegate = self;
//    sizeString = @"大";
    
    
    self.breedTextField.placeholder = @"請輸入品種(ex.米克斯..)";
    self.breedTextField.delegate = self;
    
    self.locationTextField.placeholder = @"請輸入發現地址";
    self.locationTextField.delegate = self;
    
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
    

    
    self.timeTextField.delegate = self;
    // 建立 UIDatePicker
    datePicker = [[UIDatePicker alloc]init];
    // locale.timeZone不用設,預設就是看裝置的地區與時區
//    datelocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
//    datePicker.locale = datelocale;
//    datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT+8"];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    // 以下這行是重點 (螢光筆畫兩行) 將 UITextField 的 inputView 設定成 UIDatePicker
    // 則原本會跳出鍵盤的地方 就改成選日期了
    self.timeTextField.inputView = datePicker;
    
    //取得datePicker的值
    [datePicker addTarget:self action:@selector(getTime) forControlEvents:UIControlEventValueChanged];
    
    
    // 建立 UIToolbar
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    // 選取日期完成鈕 並給他一個 selector
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
                                                                          action:@selector(cancelPicker)];
    // 把按鈕加進 UIToolbar
    toolBar.items = [NSArray arrayWithObject:right];
    // 以下這行也是重點 (螢光筆畫兩行)
    // 原本應該是鍵盤上方附帶內容的區塊 改成一個 UIToolbar 並加上完成鈕
    self.timeTextField.inputAccessoryView = toolBar;
    
    
    // 創建appearTextView
    self.appearTextView.backgroundColor= [UIColor whiteColor];
    self.appearTextView.text = @"請輸入毛孩子的外觀或其餘特徵";
    self.appearTextView.textColor = [UIColor grayColor];
    self.appearTextView.delegate = self;
    self.appearTextView.backgroundColor = [UIColor clearColor];
    
    /* 測試picker選取資料
    NSDateFormatter *df = [NSDateFormatter new];
    NSString *UpdateTimeString = [NSDateFormatter
                                  dateFormatFromTemplate:@"yyyy-MM-dd hh:mm:ss"
                                  options:0
                                  locale:[NSLocale currentLocale]];
    [df setDateFormat:UpdateTimeString];
    NSString *Test_df = [NSString stringWithFormat:@"%@",[df stringFromDate:datePicker.date]];
    NSLog(@"%@",Test_df);*/
    
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
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back2.png"]];
    UIImage *backgroundImage = [UIImage imageNamed:@"back2.png"];
    UIImageView *backgroundImageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundImageView.image=backgroundImage;
    [self.view insertSubview:backgroundImageView atIndex:0];

    
    
}


- (IBAction)locateBtnPressed:(id)sender {
    
    //經緯度轉地址
    CLGeocoder *geocoder = [CLGeocoder new];

    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
    [geocoder reverseGeocodeLocation:targetLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"ReverseGeocode fail: %@",error);
            return ;
        }
        
        CLPlacemark *placemark = placemarks.firstObject;
//        NSDictionary *address = placemark.addressDictionary;
//        self.locationTextField.text =[NSString stringWithFormat:@"%@",address[@"FormattedAddressLines"][0]];
        self.locationTextField.text = [NSString stringWithFormat:@"%@%@%@%@%@",placemark.country,placemark.administrativeArea,placemark.locality,placemark.thoroughfare,placemark.subThoroughfare];
//        NSLog(@"%@,%@,%@,%@,%@,%@",placemark.country,placemark.locality,placemark.administrativeArea,placemark.thoroughfare,placemark.subThoroughfare,placemark.postalCode);
    }];
}


// 按下完成鈕後的 method
-(void) cancelPicker {
    // endEditing: 是結束編輯狀態的 method
    if ([self.view endEditing:NO]) {
        // 以下幾行是測試用 可以依照自己的需求增減屬性
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy-MM-dd" options:0 locale:datelocale];
//        [formatter setDateFormat:dateFormat];
//        [formatter setLocale:datelocale];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        // 將選取後的日期 填入 UITextField
        self.timeTextField.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:datePicker.date]];
        
        
//        [NSString stringWithFormat:@"%@",datePicker.date];
//        [NSString stringWithFormat:@"%@",[formatter stringFromDate:datePicker.date]];
    }
}

-(void) getTime{
    NSLog(@"%@",datePicker.date);
}

#pragma mark - UITextViewDelegate
//實作appearTextView的類placeholder方法
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(textView.text.length < 1){
        textView.text = @"請輸入毛孩子的外觀或其餘特徵";
        textView.textColor = [UIColor grayColor];
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"請輸入毛孩子的外觀或其餘特徵"]){
        textView.text=@"";
        textView.textColor=[UIColor blackColor];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return sizeArray.count;
}


#pragma mark UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [sizeArray objectAtIndex:row];
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    sizeString = [sizeArray objectAtIndex:row];
//    NSLog(@"%@",sizeString);
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
}


- (IBAction)done:(id)sender {
    [self updateLocation];
    
}

- (IBAction)Camera:(id)sender {
    
    UIImagePickerController *pickerCtrl = [[UIImagePickerController alloc] init];
    pickerCtrl.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerCtrl.delegate = self;
    [self presentViewController:pickerCtrl animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
 
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    uploadImage = image;
    self.imageView.image = image;
//    [self imageUpload:image];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//上傳圖片方法
- (void) imageUpload:(UIImage *) image{
    
    NSData *imageData = UIImageJPEGRepresentation(image, .1);
    NSURL *url = [NSURL URLWithString:@"https://codomo.000webhostapp.com/petImage_upload.php"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    // 設定唯一圖片名稱
    NSUUID *uuid = [NSUUID UUID];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[uuid UUIDString]];
    
    NSData *body = [self bodyOfFile:imageName imageData:imageData request:request];
    
    // 設定圖片網址
    imageUrl = [NSString stringWithFormat:@"https://codomo.000webhostapp.com/uploads/%@",imageName];
    
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
        });
    }];
    [task resume];
}


#pragma mark Http file Upload body
-(NSData*)bodyOfFile:(NSString*)fileName imageData:(NSData*)imageData request:(NSMutableURLRequest *)request{
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"%@\"\r\n",fileName];
    [body appendData:[contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return body;
}


-(void)insertData{
    
    NSString *breed = self.breedTextField.text;
    NSString *location = self.locationTextField.text;
    NSString *appearance = self.appearTextView.text;
    NSString *displayTime = self.timeTextField.text;
    
    if ([self.appearTextView.text isEqualToString:@"請輸入毛孩子的外觀或其餘特徵"]) {
        appearance = @"";
    }
    // 設定時間,UpdateTimeString儲存統一時間格式
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    myDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *UpdateTimeString = [NSString stringWithFormat:@"%@",[myDateFormatter stringFromDate: datePicker.date]];
    NSLog(@"%@",UpdateTimeString);
    
    NSURL *url = [NSURL URLWithString:@"https://codomo.000webhostapp.com/insertPetData.php"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    //POST
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    
    
    NSString *params = [NSString stringWithFormat:@"breed=%@&size=%@&location=%@&lat=%@&lon=%@&appearance=%@&UpdateTime=%@&displayTime=%@&imageUrl=%@&UserName=%@",
                        breed,sizeString,location,lat,lon,appearance,UpdateTimeString,displayTime,imageUrl,[userDefaults objectForKey:@"userID"]];
    NSData *body = [params dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:body];
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ( error ){
            NSLog(@"error %@",error);
        }else{
            NSString *status = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"status = %@",status);
            //自己要檢查是否有錯誤回傳
            
            NSDictionary *newItem = @{@"breed":self.breedTextField.text,@"size":sizeString,@"location":self.locationTextField.text,@"lat":lat,@"lon":lon,@"appearance":self.appearTextView.text,@"UpdateTime":UpdateTimeString,@"displayTime":displayTime,@"imageUrl":imageUrl};
            [self.findPetData addObject:newItem];
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.findPetData.count-1 inSection:0];
//                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            });
        }
        
        
    }];
    [task resume];
    
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    //第0個位置資訊，表示為最新的位置資訊
    CLLocation * location = [locations objectAtIndex:0];

    lat = [[NSString alloc] initWithFormat:@"%f",location.coordinate.latitude];     //緯度
    lon = [[NSString alloc] initWithFormat:@"%f",location.coordinate.longitude];    //經度

    //取得經緯度資訊，並組合成字串
//    NSString * currentLocation = [[NSString alloc] initWithFormat:@"緯度:%f, 經度:%f"
//                      , location.coordinate.latitude
//                      , location.coordinate.longitude];

//    [self.locationTextField setText:currentLocation];
}

//做經緯度轉地址再上傳
-(void)updateLocation{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder geocodeAddressString:self.locationTextField.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        
        if (error) {
            NSLog(@"Geocode fail: %@",error);
            return ;
        }
        
        CLPlacemark *targetPlacemark = placemarks.firstObject;
        NSLog(@"targetPlacemark: %f,%f",targetPlacemark.location.coordinate.latitude,targetPlacemark.location.coordinate.longitude);
        lat=[NSString stringWithFormat:@"%f",targetPlacemark.location.coordinate.latitude];
        lon=[NSString stringWithFormat:@"%f",targetPlacemark.location.coordinate.longitude];
        
        [self imageUpload:uploadImage];
        [self insertData];
        
        // 回到上一個ViewController
        //    [self.navigationController popViewControllerAnimated:YES];
        //    [self dismissViewControllerAnimated:YES completion:nil];
        //    [self.navigationController popToRootViewControllerAnimated:YES];
        
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        NearPetTableViewController *controllerD = [storyboard instantiateViewControllerWithIdentifier:@"NearPetTableViewController"];
        [self.navigationController pushViewController:controllerD animated:YES];
        /* 跳到下一個ViewController
         
         */
        
        
    }];
}

#pragma mark UITextFieldDelegate
//收回鍵盤
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

////收回鍵盤
//-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是return，即按下return
//        return NO;
//        //NO，就代表return失效，即頁面上按下return，不會出現換行，如果為YES，則會輸入換行
//    }
//    return YES;
//}

//點擊空白處可收回鍵盤
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
