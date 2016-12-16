//
//  ImageOperation.m
//  FindPet
//
//  Created by user51 on 2016/12/8.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import "ImageOperation.h"

@implementation ImageOperation

-(void)main{
    
    if( [self isCancelled]){
        return;
    }
    // download image from imageurl
    //GCD 不易取消,會每次捲動畫面皆下載檔案
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        NSData *data = [NSData dataWithContentsOfURL:self.imageUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:self.indexPath];
            if( cell1 ){    //檢查該位置的cell是否有值,有值才更新
                cell1.imageView.image = [UIImage imageWithData:data];
                [cell1 setNeedsLayout];     //重新呼叫cell裡面的機制
            }
        });
        
    });
}

@end
