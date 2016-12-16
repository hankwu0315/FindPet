//
//  ImageOperation.h
//  FindPet
//
//  Created by user51 on 2016/12/8.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface ImageOperation : NSOperation

@property(nonatomic) NSURL *imageUrl;
@property(nonatomic) UITableView *tableView;
@property(nonatomic) NSIndexPath *indexPath;

@end
