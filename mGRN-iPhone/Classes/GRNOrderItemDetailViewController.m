//
//  GRNOrderItemDetailViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 22/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNOrderItemDetailViewController.h"
#import "PurchaseOrderItem+Management.h"
#import "GRNItem+Management.h"
#import "WBS+Management.h"
#import "CoreDataManager.h"
#import "GRN.h"
#import "RejectionReasons+Management.h"
#import "GRNM1XHeader.h"
#import "M1XmGRNService.h"
#import "LoadingView.h"

#define WBSCodeText @"Select WBS Code"

@interface GRNOrderItemDetailViewController () <M1XmGRNDelegate>
@property (nonatomic, strong) UIView *loadingView;
@end

@implementation GRNOrderItemDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self displaySelectedItem];
}

-(void)displaySelectedItem
{
    PurchaseOrderItem *item = self.grnItem.purchaseOrderItem;
    
    if (![self.grnItem.grn.purchaseOrder.contract.useWBS boolValue] && !self.wbsButton.hidden)
    {
        self.wbsButton.hidden = YES;
        self.wbsCodeLabel.hidden = YES;
        CGRect frame = self.viewBelowWbsCode.frame;
        frame.origin = self.wbsCodeLabel.frame.origin;
        self.viewBelowWbsCode.frame = frame;
    }
    else
    {
        //Get wbs if not present
        if (![[WBS fetchWBSCodesForContractNumber:self.grnItem.grn.purchaseOrder.contract.number
                                            inMOC:[CoreDataManager moc]] count])
        {
            [self getWBS];
        }
        else
        {
            
            WBS *wbs = [WBS fetchWBSWithCode:self.grnItem.wbsCode.length? self.grnItem.wbsCode : item.wbsCode inMOC:[CoreDataManager moc]];
            NSString *wbsCode = wbs.code.length? [NSString stringWithFormat:@"%@: %@",wbs.code,wbs.codeDescription] : WBSCodeText;
            [self.wbsButton setTitle:wbsCode forState:UIControlStateNormal];
        }
    }
    
    self.itemLabel.text = item.itemNumber;
    self.descriptionLabel.text = item.itemDescription;
    [self.titleButton setTitle:item.itemDescription forState:UIControlStateNormal];
    self.expected.text = [NSString stringWithFormat:@"EA (%.02f expected)",[item.quantityBalance doubleValue]];
    
    
    //Set Delivered and rejected quantities rounded to 2 decimal places
    double delivered = [self.grnItem.quantityDelivered doubleValue] > 0? [self.grnItem.quantityDelivered doubleValue] : [item.quantityBalance doubleValue];
    double rejected = [self.grnItem.quantityRejected doubleValue];
    
    self.quantityDelivered.text = delivered > 0.0? [NSString stringWithFormat:@"%.02f",delivered] : @"";
    self.quantityRejected.text = rejected > 0.0? [NSString stringWithFormat:@"%.02f",rejected] : @"";
    
    //Set Reason: If either rejected quantity is null or rejection code is null show "No Reason" as title
    RejectionReasons *reason = [RejectionReasons fetchReasonWithCode:self.grnItem.exception
                                                               inMOC:[CoreDataManager moc]];
    [self.reasonButton setTitle:reason == nil || rejected == 0.0 ? @"No Reason" : reason.codeDescription forState:UIControlStateNormal];
    
    self.note.text = self.grnItem.notes;
    
    //Show or hide serial number
    if ([item.plant boolValue])
    {
        self.serialNumber.hidden = NO;
        self.serialNumberLabel.hidden = NO;
        self.serialNumber.text = self.grnItem.serialNumber.length? self.grnItem.serialNumber : @"";
    }
    else
    {
        self.serialNumber.hidden = YES;
        self.serialNumberLabel.hidden = YES;
    }
}

-(void)getWBS
{
    [self startLoading];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        M1XmGRNService *service = [[M1XmGRNService alloc] init];
        service.delegate = self;
        NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
        kco = [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
        [service GetWBSWithHeader:[GRNM1XHeader Header]
                   contractNumber:self.grnItem.grn.purchaseOrder.contract.number
                              kco:kco];
    }];
}

-(void)onAPIRequestFailure:(M1XResponse *)response
{
    
}

-(void)onAPIRequestSuccess:(NSDictionary *)response requestType:(RequestType)requestType
{
    NSArray *wbsData = [response objectForKey:@"wbsCodes"];
    NSManagedObjectContext *context = [CoreDataManager moc];
    for (NSDictionary *wbs in wbsData)
    {
        [WBS insertWBSCodesWithData:wbs
                        forContract:self.grnItem.grn.purchaseOrder.contract
             inManagedObjectContext:context
                              error:nil];
    }
    WBS *wbs = [WBS fetchWBSWithCode:self.grnItem.wbsCode.length? self.grnItem.wbsCode : self.grnItem.purchaseOrderItem.wbsCode inMOC:[CoreDataManager moc]];
    NSString *wbsCode = wbs.code.length? [NSString stringWithFormat:@"%@: %@",wbs.code,wbs.codeDescription] : WBSCodeText;
    [self.wbsButton setTitle:wbsCode forState:UIControlStateNormal];
    [self stopLoading];
}

-(void)startLoading
{
    [self.view addSubview:self.loadingView];
}

-(void)stopLoading
{
    [self.loadingView removeFromSuperview];
}


-(UIView*)loadingView
{
    if(!_loadingView)
    {
        _loadingView = [[LoadingView alloc] initWithFrame:self.view.bounds];
    }
    return _loadingView;
}
@end
