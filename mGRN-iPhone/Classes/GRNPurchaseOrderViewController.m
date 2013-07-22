//
//  GRNPurchaseOrderViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 20/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNPurchaseOrderViewController.h"
#import "Contract+Management.h"
#import "CoreDataManager.h"
#import "PurchaseOrder+Management.h"
#import "M1XmGRNService.h"
#import "GRNM1XHeader.h"
#import <QuartzCore/QuartzCore.h>
#import "GRNPODetailViewController.h"

#define TagPO 1
#define TagDescription 2
#define TagSupplier 3
#define TagAttention 4
#define TagAttentionLine 5


@interface GRNPurchaseOrderViewController ()

@end

@implementation GRNPurchaseOrderViewController

#pragma mark - Getters and Setters

-(void)setContract:(Contract *)contract
{
    _contract = contract;
    self.dataArray = [self getDataArray];
    if (self.dataArray.count)
    {
        //TODO: Show loading view
        [self.tableView reloadData];
    }
    else
    {
        [self getDataFromAPI];
    }
}

#pragma mark - Get Data

-(NSArray*)getDataArray
{
    NSArray *array = [PurchaseOrder fetchPurchaseOrdersForContractNumber:self.contract.number
                                                                   inMOC:[CoreDataManager moc]];
    return array;
}


-(void)getDataFromAPI
{
    if ([CoreDataManager hasSessionExpired])
    {
        //TODO
        return;
    }
    [self startLoading];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.service GetPurchaseOrdersWithHeader:[GRNM1XHeader Header]
                                   contractNumber:self.contract.number
                                              kco:self.kco
                                 includeLineItems:YES];
    }];
}

-(void)onAPIRequestSuccess:(NSDictionary *)orderData requestType:(RequestType)requestType
{
    NSManagedObjectContext *context = [CoreDataManager moc];
    NSError *error = NULL;
    NSArray *orders = [orderData objectForKey:@"purchaseOrders"];
    for (NSDictionary *dict in orders)
    {
        @try {
            [PurchaseOrder insertPurchaseOrderWithData:dict
                                           forContract:self.contract
                                inManagedObjectContext:context
                                                 error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }

    }
    [context save:nil];
    self.dataArray = [self getDataArray];
    self.errorLabel.hidden = self.dataArray.count == 0? NO : YES;
    [self.tableView reloadData];
    [self stopLoading];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GRNPODetailViewController *vc = segue.destinationViewController;
    vc.purchaseOrder = [self.dataArray objectAtIndex:[self.tableView indexPathForSelectedRow].section];
}

#pragma mark - Table Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"purchaseDetail" sender:self];
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.0;
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - Table Data Source

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PurchaseOrderCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell != nil)
    {
        PurchaseOrder *purchaseOrder = [self.dataArray objectAtIndex:indexPath.section];
        
        UILabel *po = (UILabel*)[cell viewWithTag:TagPO];
        po.text = purchaseOrder.orderNumber;
        
        UILabel *desc = (UILabel*)[cell viewWithTag:TagDescription];
        desc.text = purchaseOrder.orderDescription;
        
        UILabel *supplier = (UILabel*)[cell viewWithTag:TagSupplier];
        supplier.text = purchaseOrder.orderName;
        
        UILabel *attention = (UILabel*)[cell viewWithTag:TagAttention];
        attention.text = purchaseOrder.attention;
        [attention sizeToFit];
        
        UIView *attentionLine = [cell viewWithTag:TagAttentionLine];
        CGRect frame = attentionLine.frame;
        frame.size.width = attention.frame.size.width;
        attentionLine.frame = frame;
    }
    return cell;
}

#pragma mark - Search

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchString
{
    if (searchString.length)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderNumber CONTAINS[c] %@ OR orderDescription CONTAINS[c] %@ OR  orderName CONTAINS[c] %@ OR attention CONTAINS[c] %@",searchString,searchString, searchString, searchString];
        self.dataArray = [[self getDataArray] filteredArrayUsingPredicate:predicate];
    }
    else
    {
        self.dataArray = [self getDataArray];
    }
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [self setErrorLabel:nil];
    [super viewDidUnload];
}
@end
