//
//  GRNPODetailViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 20/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNPODetailViewController.h"
#import "PurchaseOrderItem+Management.h"
#import "GRNOrderItemViewController.h"
#import "CoreDataManager.h"
#import "GRN+Management.h"

@interface GRNPODetailViewController ()
//@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation GRNPODetailViewController

-(void)setPurchaseOrder:(PurchaseOrder *)purchaseOrder
{
    _purchaseOrder = purchaseOrder;
    self.dataArray = [self getDataArray];
//    [self.tableView reloadData];
}

-(void)viewDidLoad
{
    self.contractName.text = self.purchaseOrder.contract.name;
    self.contractNumber.text = self.purchaseOrder.contract.number;
    self.po.text = self.purchaseOrder.orderNumber;
    self.poDescription.text = self.purchaseOrder.orderDescription;
    self.supplier.text = self.purchaseOrder.orderName;
//    self.dataArray = [self getDataArray];
}

-(NSArray*)getDataArray
{
    return [[self.purchaseOrder.lineItems allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"itemNumber" ascending:YES]]];
}

- (void)viewDidUnload {
    [self setContractNumber:nil];
    [self setContractName:nil];
    [self setPo:nil];
    [self setPoDescription:nil];
    [self setSupplier:nil];
    [self setTableView:nil];
    [self setSdnView:nil];
    [self setSdn:nil];
    [super viewDidUnload];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"grn"])
    {
        
        GRNOrderItemViewController *vc = segue.destinationViewController;
        vc.purchaseOrder = self.purchaseOrder;
        vc.selectedIndexPath = self.tableView.indexPathForSelectedRow;
    }
}

#pragma mark - Table View Datasource

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.indentationLevel = 1;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    PurchaseOrderItem *item = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@ [%.02f %@]",item.itemNumber, item.itemDescription ,[item.quantityBalance floatValue],item.uoq];
    cell.textLabel.numberOfLines = 2;

    return cell;
    
}


-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];
    return view;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 0.0)];
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self createGRN:nil];
}

#pragma mark - IBActions

- (IBAction)createGRN:(id)sender
{
    [self performSegueWithIdentifier:@"grn" sender:self];
//    self.sdnView.frame = self.view.bounds;
//    [self.view addSubview:self.sdnView];
//    [self.sdn becomeFirstResponder];
}

- (IBAction)next:(id)sender {
    [self performSegueWithIdentifier:@"grn" sender:self];
}

- (IBAction)closeSDN:(id)sender {
    [self.sdnView removeFromSuperview];
}
@end
