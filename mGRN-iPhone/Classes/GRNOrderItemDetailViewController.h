//
//  GRNOrderItemDetailViewController.h
//  mGRN-iPhone
//
//  Created by Anum on 22/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GRNItem;
@interface GRNOrderItemDetailViewController : UIViewController

@property (nonatomic, strong) GRNItem *grnItem;

@property (strong, nonatomic) IBOutlet UIButton *titleButton;
@property (strong, nonatomic) IBOutlet UILabel *itemLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UITextField *quantityDelivered;
@property (strong, nonatomic) IBOutlet UITextField *quantityRejected;
@property (strong, nonatomic) IBOutlet UITextView *note;
@property (strong, nonatomic) IBOutlet UILabel *expected;
@property (strong, nonatomic) IBOutlet UIButton *wbsButton;
@property (strong, nonatomic) IBOutlet UIButton *reasonButton;
@property (strong, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (strong, nonatomic) IBOutlet UITextField *serialNumber;
@property (strong, nonatomic) IBOutlet UILabel *wbsCodeLabel;
@property (strong, nonatomic) IBOutlet UIView *viewBelowWbsCode;

@end
