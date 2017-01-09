//
//  PetPointAnnotation.h
//  FindPet
//
//  Created by Han on 2017/1/8.
//  Copyright © 2017年 ChungHan Wu. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PetPointAnnotation : MKPointAnnotation

@property (nonatomic) UIImage *petImage;
@property (nonatomic,strong) NSString *breedLabelText;
@property (nonatomic) NSString *sizeLabelText;
@property (nonatomic) NSString *locationLabelText;
@property (nonatomic) NSString *timeLabelText;
@property (nonatomic) NSString *appearanceTextViewText;
@property (nonatomic) NSString *lat;
@property (nonatomic) NSString *lon;

@end
