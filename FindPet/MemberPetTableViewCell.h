//
//  MemberPetTableViewCell.h
//  FindPet
//
//  Created by 吳重漢 on 2017/1/19.
//  Copyright © 2017年 ChungHan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberPetTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *breedLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *findImageView;

@end
