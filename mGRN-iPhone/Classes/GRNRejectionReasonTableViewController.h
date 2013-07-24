//
//  GRNRejectionReasonTableViewController.h
//  mGRN-iPhone
//
//  Created by Anum on 24/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RejectionReasons;

@protocol RejectionReasonDelegate <NSObject>
-(void)RejectionReasonDidSelectReason:(RejectionReasons*)reason;
@end

@interface GRNRejectionReasonTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSString *selectedReasonCode;
- (IBAction)done:(id)sender;
@end
