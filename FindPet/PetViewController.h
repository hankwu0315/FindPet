//
//  PetViewController.h
//  FindPet
//
//  Created by user51 on 2016/12/20.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface PetViewController : UIViewController
@property (nonatomic) UIImage *petImage;
@property (nonatomic,strong) NSString *breedLabelText;
@property (nonatomic) NSString *sizeLabelText;
@property (nonatomic) NSString *locationLabelText;
@property (nonatomic) NSString *timeLabelText;
@property (nonatomic) NSString *appearanceTextViewText;
@property (nonatomic) NSString *lat;
@property (nonatomic) NSString *lon;
@end
