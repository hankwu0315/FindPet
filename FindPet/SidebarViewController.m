//
//  SidebarViewController.m
//  FindPet
//
//  Created by user51 on 2016/11/24.
//  Copyright © 2016年 ChungHan Wu. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "AccountTableViewCell.h"
#import "StartViewController.h"

@interface SidebarViewController (){
    NSUserDefaults *userDefaults;
}

@end

@implementation SidebarViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"IMG_0584.JPG"]];
}

-(void)viewWillAppear:(BOOL)animated{
    userDefaults = [NSUserDefaults standardUserDefaults];
    [self.tableView reloadData];
    
    self.menuItems = @[@"nearPet",@"findPet"];
    
    //    self.menuItems = @[@"title",@"account", @"nearPet",@"findPet"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
//    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return self.menuItems.count;
            break;
        default:
            return 0;
            break;
    }
    
//    return self.menuItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:{
            UITableViewCell *titleCell = [tableView dequeueReusableCellWithIdentifier:@"title"];
            return titleCell;
            break;
        }
        
        case 1:{
            AccountTableViewCell *accountCell = [tableView dequeueReusableCellWithIdentifier:@"account"];
            if ([[[userDefaults dictionaryRepresentation] allKeys] containsObject:@"userID"]) {
                accountCell.accountLabel.text = [userDefaults objectForKey:@"userID"];
            } else {
                accountCell.accountLabel.text = @"訪客";
            }
            return accountCell;
            break;
        }
            
        case 2:{
            NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.contentView.backgroundColor = [UIColor clearColor];
            return cell;
            break;
            
        }
            
        default:{
            return 0;
            break;
        }
    }
//    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    cell.contentView.backgroundColor = [UIColor clearColor];
//    
//    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //未登入不能新增資料
    switch (indexPath.section) {
        case 0:
            return indexPath;
            break;
        case 1:
            return indexPath;
            break;
        case 2:
            if (![[[userDefaults dictionaryRepresentation] allKeys] containsObject:@"userID"]) {
                if (indexPath.row == 1) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提醒" message:@"欲發布毛孩子訊息須先「登入」" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"登入" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        StartViewController *startViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"startNC"];
                        [self presentViewController:startViewController animated:YES completion:nil];
                    }];
                    [alertController addAction:cancelAction];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return nil;
                }
                return indexPath;
            }
            return indexPath;
            break;
            
        default:
            return indexPath;
            break;
    }
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
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[self.menuItems objectAtIndex:indexPath.row] capitalizedString];
    
}


@end
