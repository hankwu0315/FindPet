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

@interface FoundPetViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate>
{
    NSArray *sizeArray;
    NSString *sizeString;
    
    UIImage *uploadImage;
    NSString *imageUrl;
    
    UIDatePicker *datePicker;
    NSLocale *datelocale;

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

@implementation FoundPetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //    [self.Camera setImage:[UIImage imageNamed:@"camera-6.png"] forState:UIControlStateNormal];
    self.title = @"發現遺失毛小孩";
    
    
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
    self.locationTextField.placeholder = @"請輸入發現地址";
    
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
    
    /* 測試picker選取資料
    NSDateFormatter *df = [NSDateFormatter new];
    NSString *UpdateTimeString = [NSDateFormatter
                                  dateFormatFromTemplate:@"yyyy-MM-dd hh:mm:ss"
                                  options:0
                                  locale:[NSLocale currentLocale]];
    [df setDateFormat:UpdateTimeString];
    NSString *Test_df = [NSString stringWithFormat:@"%@",[df stringFromDate:datePicker.date]];
    NSLog(@"%@",Test_df);*/
    
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
    
    NSData *imageData = UIImageJPEGRepresentation(image, .5);
    NSURL *url = [NSURL URLWithString:@"http://localhost:8888/petImage_upload.php"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    // 設定唯一圖片名稱
    NSUUID *uuid = [NSUUID UUID];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[uuid UUIDString]];
    
    NSData *body = [self bodyOfFile:imageName imageData:imageData request:request];
    
    // 設定圖片網址
    imageUrl = [NSString stringWithFormat:@"http://localhost:8888/uploads/%@",imageName];
    
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
    
    // 設定時間,UpdateTimeString儲存統一時間格式
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    myDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *UpdateTimeString = [NSString stringWithFormat:@"%@",[myDateFormatter stringFromDate: datePicker.date]];
    NSLog(@"%@",UpdateTimeString);
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:8888/insertPetData.php"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    //POST
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *params = [NSString stringWithFormat:@"breed=%@&size=%@&location=%@&appearance=%@&UpdateTime=%@&displayTime=%@&imageUrl=%@",
                        breed,sizeString,location,appearance,UpdateTimeString,displayTime,imageUrl];
    NSData *body = [params dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:body];
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ( error ){
            NSLog(@"error %@",error);
        }else{
            NSString *status = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"status = %@",status);
            //自己要檢查是否有錯誤回傳
            
            NSDictionary *newItem = @{@"breed":self.breedTextField.text,@"size":sizeString,@"location":self.locationTextField.text,@"appearance":self.appearTextView.text,@"UpdateTime":UpdateTimeString,@"displayTime":displayTime,@"imageUrl":imageUrl};
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
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
