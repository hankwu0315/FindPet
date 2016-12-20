//
//  Pet.h
//  FindPet
//
//  Created by user51 on 2016/12/20.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface Pet : NSObject

@property (nonatomic) NSString *breed;
@property (nonatomic) NSString *size;
@property (nonatomic) NSString *location;
@property (nonatomic) NSString *appearance;
@property (nonatomic) NSString *UpdateTime;
@property (nonatomic) NSString *displayTime;
@property (nonatomic) NSString *imageUrl;

-(UIImage*)image; //NShomeDirectory + Documents +檔名，取得圖檔
-(UIImage*)thumnailImage;//放縮圖

@end
