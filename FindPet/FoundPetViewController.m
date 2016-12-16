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

@interface FoundPetViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSArray *sizeArray;
    NSString *sizeString;

}
@property (weak, nonatomic) IBOutlet UIButton *Camera;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *breedTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *sizePickerView;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
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
    
    
    // 創建appearTextView
    self.appearTextView.backgroundColor= [UIColor whiteColor];
    self.appearTextView.text = @"請輸入毛孩子的外觀或其餘特徵";
    self.appearTextView.textColor = [UIColor grayColor];
    self.appearTextView.delegate = self;
    
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
//    [self imageUpload:self.imageView.image];
    [self insertData];
    
}

- (IBAction)Camera:(id)sender {
    
    UIImagePickerController *pickerCtrl = [[UIImagePickerController alloc] init];
    pickerCtrl.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerCtrl.delegate = self;
    [self presentViewController:pickerCtrl animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
 
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    [self imageUpload:image];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//上傳圖片方法
- (void) imageUpload:(UIImage *) image{
    
    NSData *imageData = UIImageJPEGRepresentation(image, .9);
    NSURL *url = [NSURL URLWithString:@"http://localhost:8888/petImage_upload.php"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSData *body = [self bodyOfFile:@"image.jpg" imageData:imageData request:request];
    
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
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:8888/insertPetData.php"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    //POST
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *params = [NSString stringWithFormat:@"breed=%@&size=%@&location=%@&appearance=%@",
                        breed,sizeString,location,appearance];
    NSData *body = [params dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:body];
    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ( error ){
            NSLog(@"error %@",error);
        }else{
            NSString *status = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"status = %@",status);
            //自己要檢查是否有錯誤回傳
            
            NSDictionary *newItem = @{@"breed":self.breedTextField.text,@"size":sizeString,@"location":self.locationTextField.text,@"appearance":self.appearTextView.text};
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
    // 上傳資料
    [self insertData];
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
