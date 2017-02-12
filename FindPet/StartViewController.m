//
//  StartViewController.m
//  FindPet
//
//  Created by 吳重漢 on 2017/1/17.
//  Copyright © 2017年 ChungHan Wu. All rights reserved.
//

#import "StartViewController.h"
#import "SWRevealViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController{
    NSUserDefaults *userDefaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //navigationBar 透明
    //方法一
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;


    
    //方法二
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
    //                                                  forBarMetrics:UIBarMetricsDefault];
    //    self.navigationController.navigationBar.shadowImage = [UIImage new];
    //    self.navigationController.navigationBar.translucent = YES;
    //    self.navigationController.view.backgroundColor = [UIColor clearColor];
    //    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    //    =================================================================================
    
    //加入背景圖
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cat-iphone-wallpaper-HD10.jpg"]]];
    UIImage *backgroundImage = [UIImage imageNamed:@"start1.jpg"];
    UIImageView *backgroundImageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundImageView.image=backgroundImage;
    [self.view insertSubview:backgroundImageView atIndex:0];
    
    //毛玻璃效果
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
//    blurEffectView.frame = backgroundImageView.bounds;
//    [backgroundImageView addSubview:blurEffectView];


    userDefaults = [NSUserDefaults standardUserDefaults];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)skipBtn:(id)sender {
    
    if ([[[userDefaults dictionaryRepresentation] allKeys] containsObject:@"userID"]) {
        [userDefaults removeObjectForKey:@"userID"];
    }
    
    SWRevealViewController *swRevealViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
    [self presentViewController:swRevealViewController animated:YES completion:nil];
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
