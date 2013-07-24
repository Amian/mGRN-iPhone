//
//  GRNWbsTableViewController.h
//  mGRN-iPhone
//
//  Created by Anum on 24/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WBS;


@protocol WbsDelegate <NSObject>
-(void)wbsSelected:(WBS*)wbs;
@end

@interface GRNWbsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSString *selectedWbsCode;
@property (nonatomic, retain) NSArray *dataArray;
- (IBAction)done:(id)sender;
@end
