//
//  Pet.m
//  FindPet
//
//  Created by user51 on 2016/12/20.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import "Pet.h"

@implementation Pet

//-(UIImage *)image{
//    
//    return image;
//}
//
//-(UIImage *)thumnailImage{
//    UIImage *image = [self image];//有原圖才做縮圖
//    if ( !image){
//        return nil;
//    }
//    
//    CGSize thumbnailSize = CGSizeMake(50, 50); //設定縮圖大小
//    CGFloat scale = [UIScreen mainScreen].scale; //找出目前螢幕的scale，視網膜技術為2.0
//    //產生畫布，第一個參數指定大小,第二個參數YES:不透明（黑色底）,false表示透明背景,scale為螢幕scale
//    UIGraphicsBeginImageContextWithOptions(thumbnailSize, YES, scale);
//    
//    //計算長寬要縮圖比例，取最大值MAX會變成UIViewContentModeScaleAspectFill
//    //最小值MIN會變成UIViewContentModeScaleAspectFit
//    CGFloat widthRatio = thumbnailSize.width / image.size.width;
//    CGFloat heightRadio = thumbnailSize.height / image.size.height;
//    CGFloat ratio = MAX(widthRatio,heightRadio);
//    
//    CGSize imageSize = CGSizeMake(image.size.width*ratio, image.size.height*ratio);
//    [image drawInRect:CGRectMake(-(imageSize.width-thumbnailSize.width)/2.0, -(imageSize.height-thumbnailSize.height)/2.0,
//                                 imageSize.width, imageSize.height)];
//    
//    //取得畫布上的縮圖
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    //關掉畫布
//    UIGraphicsEndImageContext();
//    return image;
//}

@end
