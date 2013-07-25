//
//  GRNBaseViewController.h
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M1XmGRNService.h"
#import "LoadingView.h"

typedef enum
{
    TableStateNormal,
    TableStateSelected
}TableState;

@interface GRNBaseViewController : UIViewController <M1XmGRNDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic) TableState state;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) M1XmGRNService *service;
@property (nonatomic, strong) NSArray *dataArray;
@property (readonly) NSString *kco;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSIndexPath *selectedIndex;

- (IBAction)logout:(id)sender;
- (IBAction)showInfo:(id)sender;
//-(IBAction)back:(id)sender;
-(void)getDataFromAPI;
- (IBAction)search:(id)sender;
-(void)startLoading;
-(void)stopLoading;

@end
