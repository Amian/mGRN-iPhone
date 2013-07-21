//
//  GRNOrderItemViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 20/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNOrderItemViewController.h"
#import "PurchaseOrderItem+Management.h"
#import "GRN+Management.h"
#import "GRNItem+Management.h"
#import "CoreDataManager.h"

@interface GRNOrderItemViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation GRNOrderItemViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.grn = [GRN grnForPurchaseOrder:self.purchaseOrder
                 inManagedObjectContext:[CoreDataManager moc]
                                  error:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
//    [self.tableView beginUpdates];
//    [self.tableView selectRowAtIndexPath:self.selectedIndexPath
//                           animated:NO
//                     scrollPosition:UITableViewScrollPositionMiddle];
//    [self.tableView endUpdates];

}

- (IBAction)next:(id)sender {
    [self performSegueWithIdentifier:@"completeGRN" sender:self];
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
    if (self.selectedIndexPath && self.selectedIndexPath.row == indexPath.row)
    {
        cell.selected = YES;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedIndexPath)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.selected = NO;
        [tableView deselectRowAtIndexPath:self.selectedIndexPath animated:NO];
//        [tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        self.selectedIndexPath = nil;
    }
    
    [self performSegueWithIdentifier:@"itemDetails" sender:self];
}

-(NSArray*)dataArray
{
    if(!_dataArray)
    {
        _dataArray = [self.purchaseOrder.lineItems allObjects];
    }
    return _dataArray;
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
