//
//  GRNPODetailViewController.h
//  mGRN-iPhone
//
//  Created by Anum on 20/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRNBaseViewController.h"
@class PurchaseOrder;
@interface GRNPODetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *contractNumber;
@property (strong, nonatomic) IBOutlet UILabel *contractName;
@property (strong, nonatomic) IBOutlet UILabel *po;
@property (strong, nonatomic) IBOutlet UILabel *poDescription;
@property (strong, nonatomic) IBOutlet UILabel *supplier;
@property (strong, nonatomic) IBOutlet UIView *sdnView;
@property (strong, nonatomic) IBOutlet UITextField *sdn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, strong) PurchaseOrder *purchaseOrder;

- (IBAction)logout:(id)sender;

@end
