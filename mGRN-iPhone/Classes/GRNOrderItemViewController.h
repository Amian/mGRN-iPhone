//
//  GRNOrderItemViewController.h
//  mGRN-iPhone
//
//  Created by Anum on 20/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GRN;
@class PurchaseOrder;
@interface GRNOrderItemViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) GRN *grn;
@property (nonatomic, strong) PurchaseOrder *purchaseOrder;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *sdn;
@property (strong, nonatomic) IBOutlet UILabel *poLabel;

- (IBAction)acceptOrClear:(UIButton*)sender;
@end
