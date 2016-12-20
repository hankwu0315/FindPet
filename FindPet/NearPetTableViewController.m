     //
//  NearPetTableViewController.m
//  FindPet
//
//  Created by user51 on 2016/11/24.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import "NearPetTableViewController.h"
#import "SWRevealViewController.h"
#import "ImageOperation.h"
#import "NearPetTableViewCell.h"
#import "Pet.h"
#import "PetViewController.h"

@interface NearPetTableViewController ()<PetViewControllerDelegate>

@property(nonatomic) NSMutableArray *findPetData;
@property(nonatomic) NSOperationQueue *queue;

@end

@implementation NearPetTableViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.queue = [[NSOperationQueue alloc]init];
        [self.queue setMaxConcurrentOperationCount:1];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self query];
    self.title = @"附近遺失毛小孩";

    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.findPetData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"finpPetCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NearPetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    NSDictionary *item = self.findPetData[indexPath.row];
//    cell.textLabel.text = item[@"breed"];
//    cell.detailTextLabel.text = item[@"size"];
    cell.breedLabel.text = item[@"breed"];
    cell.sizeLabel.text = item[@"size"];
    
    
    // 將資料庫的圖片位置存入imageUrl
    NSURL *imageUrl = [NSURL URLWithString:item[@"imageUrl"]];
    // 將Url轉換成NSData
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    // NSData轉換成UIImage
    UIImage *image = [UIImage imageWithData:imageData];
    
    cell.findImageView.image = image;
    
    // Configure the cell...
    
    return cell;
}


-(void)query{
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:8888/petmenus_json.php"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ( error ){

//            show alertcontroller

        }else{
        
//                    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@"json = %@",content);
            NSError *error = nil;
            NSArray *pets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//
            NSDictionary *item = pets[0];
            NSLog(@"breed=%@,size=%@,location=%@,appearance=%@,UpdateTime=%@,displayTime=%@,imageUrl=%@",item[@"breed"],item[@"size"],item[@"location"],item[@"appearance"],item[@"UpdateTime"],item[@"displayTime"],item[@"imageUrl"]);
            self.findPetData = [NSMutableArray arrayWithArray:pets];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    [task resume];

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"點選到%ld筆",indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //取消選擇
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"petView"]) {
        
        PetViewController *petViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        
        Pet *newPet = self.findPetData[indexPath.row];
        
        NSDictionary *item = self.findPetData[indexPath.row];
        
        petViewController.currentPet = newPet;
        
        
        newPet.breed = item[@"breed"];
        newPet.size = item[@"size"];
        newPet.location = item[@"location"];
        newPet.appearance = item[@"appearance"];
        newPet.UpdateTime = item[@"UpdateTime"];
        newPet.displayTime = item[@"displayTime"];
        newPet.imageUrl = item[@"imageUrl"];
        
        petViewController.delegate = self;
        
    }
    
    
}






-(void)viewWillAppear:(BOOL)animated{
    [self query];
}

-(void)viewDidAppear:(BOOL)animated{
//    [self query];
}
@end
