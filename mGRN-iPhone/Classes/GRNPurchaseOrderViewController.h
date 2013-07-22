//
//  GRNPurchaseOrderViewController.h
//  mGRN-iPhone
//
//  Created by Anum on 20/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRNBaseViewController.h"
@class Contract;

@interface GRNPurchaseOrderViewController : GRNBaseViewController
@property (nonatomic, strong) Contract *contract;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@end
