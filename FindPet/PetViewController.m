//
//  PetViewController.m
//  FindPet
//
//  Created by user51 on 2016/12/20.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import "PetViewController.h"

@interface PetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *petImage;
@property (weak, nonatomic) IBOutlet UILabel *breedLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *appearanceTextView;

@end

@implementation PetViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.breedLabel.text = _currentPet.breed;
    self.sizeLabel.text = _currentPet.size;
    self.locationLabel.text = _currentPet.location;
    self.timeLabel.text = _currentPet.UpdateTime;
    self.appearanceTextView.text = _currentPet.appearance;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
