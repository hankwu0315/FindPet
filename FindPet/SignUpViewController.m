//
//  SignUpViewController.m
//  FindPet
//
//  Created by 吳重漢 on 2017/1/15.
//  Copyright © 2017年 ChungHan Wu. All rights reserved.
//

#import "SignUpViewController.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>

#define ServerApiURL @"https://codomo.000webhostapp.com/AddAccount/"


@interface SignUpViewController ()<UITextFieldDelegate>

@end

@implementation SignUpViewController{
    NSUserDefaults *userDefaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    //navigationBar 透明
    //方法一
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    
    //加入背景圖
    UIImage *backgroundImage = [UIImage imageNamed:@"cat_back.jpg"];
    UIImageView *backgroundImageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundImageView.image=backgroundImage;
    [self.view insertSubview:backgroundImageView atIndex:0];
    
    //毛玻璃效果
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    blurEffectView.frame = backgroundImageView.bounds;
    [backgroundImageView addSubview:blurEffectView];
    
    self.statusLabel.text = @"";
    self.passwordTextField.secureTextEntry = YES;
    
    _userIDTextField.delegate = self;
    _passwordTextField.delegate = self;
}
- (IBAction)signUpBtn:(id)sender {
    //將鍵盤縮回
    [_userIDTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    //判斷基本的認證結果
    if ([self validateAccount:_userIDTextField.text] && [self validatePassword:_passwordTextField.text]) {
        //啟動一個hud
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //設定hud的顯示文字
        hud.label.text = @"connecting";
        //取得userID及password
        NSString *userID = _userIDTextField.text;
        NSString *password = _passwordTextField.text;
        //設定伺服器的根目錄
        NSURL *hostRootURL = [NSURL URLWithString:ServerApiURL];
        //設定POST的內容
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"signUp", @"cmd", userID, @"userID", password, @"password", nil];
        //產生控制request的物件

        
        AFHTTPSessionManager *session = [[AFHTTPSessionManager manager]initWithBaseURL:hostRootURL];
        session.requestSerializer = [AFHTTPRequestSerializer serializer];
        session.responseSerializer = [AFHTTPResponseSerializer serializer];
        session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        
        //POST
        [session POST:@"api.php" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSLog(@"请求成功");
            //request成功之後要做的事情
            //對responseObject編碼，並輸出結果。
            NSString *response = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"response:%@",response);
            NSError *err;
            //將responseObject編碼成JSON格式
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&err];
            //取的api的key值，並輸出
            NSDictionary *apiResponse = [json objectForKey:@"api"];
            NSLog(@"apiResponse:%@",apiResponse);
            //取的signUp的key值，並輸出
            NSString *result = [apiResponse objectForKey:@"signUp"];
            NSLog(@"result:%@",result);
            //判斷signUp的key值是否等於success
            if ([result isEqualToString:@"success"]) {
                //顯示註冊成功
                UIImageView *imageView = (UIImageView *)[self.view viewWithTag:5];
                [imageView setImage:[UIImage imageNamed:@"success.png"]];
                [_statusLabel setText:@"Status:sign up successed"];
                
                [self saveNSUserDefaults];
                [userDefaults setBool:YES forKey:@"isLogin"];

                [self dismissViewControllerAnimated:YES completion:nil];
            }else {
                //顯示註冊失敗
                UIImageView *imageView = (UIImageView *)[self.view viewWithTag:5];
                [imageView setImage:[UIImage imageNamed:@"signUpFail.png"]];
                [_statusLabel setText:@"Status:sign up fail"];
                [userDefaults setBool:NO forKey:@"isLogin"];

            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"请求失敗");
            //request失敗要做的事情
            NSLog(@"request error:%@",error);
            [userDefaults setBool:NO forKey:@"isLogin"];
            UIImageView *imageView = (UIImageView *)[self.view viewWithTag:5];
            [imageView setImage:[UIImage imageNamed:@"connectError.png"]];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];

    }else {
        //基本認證失敗
        [_statusLabel setText:@"validate fail"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (BOOL)validateAccount:(NSString *)account{
    NSString *regex = @"[A-Z0-9a-z]{1,18}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:account];
}

- (BOOL)validatePassword:(NSString *)password{
    NSString *regex = @"[A-Z0-9a-z]{6,18}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:password];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark NSUserDefaults
-(void)saveNSUserDefaults{
    [userDefaults setValue:self.userIDTextField.text forKey:@"userID"];
    [userDefaults setObject:self.passwordTextField.text forKey:@"password"];
}

#pragma mark UITextFieldDelegate
//收回鍵盤
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

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
