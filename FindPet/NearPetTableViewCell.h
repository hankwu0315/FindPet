//
//  NearPetTableViewCell.h
//  FindPet
//
//  Created by Han on 2016/12/19.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearPetTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *breedLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *findImageView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end
