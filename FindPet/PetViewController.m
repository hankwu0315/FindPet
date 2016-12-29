//
//  PetViewController.m
//  FindPet
//
//  Created by user51 on 2016/12/20.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import "PetViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface PetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *petImageView;
@property (weak, nonatomic) IBOutlet UILabel *breedLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *appearanceTextView;

@end

@implementation PetViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.breedLabel.text = _breedLabelText;
    self.sizeLabel.text = _sizeLabelText;
    [self locate];
//    self.locationLabel.text = _locationLabelText;
    self.locationLabel.numberOfLines = 0; //自適應高度,字多換行
    self.timeLabel.text = _timeLabelText;
    self.appearanceTextView.text = _appearanceTextViewText;
    self.petImageView.image = _petImage;
    
    

}


- (void)locate {
    
    //經緯度轉地址
    CLGeocoder *geocoder = [CLGeocoder new];
    
    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:[self.lat doubleValue] longitude:[self.lon doubleValue]];
    [geocoder reverseGeocodeLocation:targetLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"ReverseGeocode fail: %@",error);
            return ;
        }
        
        CLPlacemark *placemark = placemarks.firstObject;
        //        NSDictionary *address = placemark.addressDictionary;
        //        self.locationTextField.text =[NSString stringWithFormat:@"%@",address[@"FormattedAddressLines"][0]];
        self.locationLabel.text = [NSString stringWithFormat:@"%@%@%@%@%@號",placemark.country,placemark.administrativeArea,placemark.locality,placemark.thoroughfare,placemark.subThoroughfare];
        //        NSLog(@"%@,%@,%@,%@,%@,%@",placemark.country,placemark.locality,placemark.administrativeArea,placemark.thoroughfare,placemark.subThoroughfare,placemark.postalCode);
    }];
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
