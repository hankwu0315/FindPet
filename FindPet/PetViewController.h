//
//  PetViewController.h
//  FindPet
//
//  Created by user51 on 2016/12/20.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pet.h"

@protocol PetViewControllerDelegate <NSObject>


@end

@interface PetViewController : UIViewController

@property (nonatomic) Pet *currentPet;

@property (nonatomic,weak) id<PetViewControllerDelegate> delegate;

@end
