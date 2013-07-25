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
#import "SDN+Management.h"
#import "GRNOrderItemDetailViewController.h"
#import "GRNCompleteGrnViewController.h"
@interface GRNOrderItemViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation GRNOrderItemViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Make sure these values are nil
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:KeyImage1];
    [defaults setObject:nil forKey:KeyImage2];
    [defaults setObject:nil forKey:KeyImage3];
    [defaults setObject:nil forKey:KeySignature];
    [defaults synchronize];
    
    self.grn = [GRN grnForPurchaseOrder:self.purchaseOrder
                 inManagedObjectContext:[CoreDataManager moc]
                                  error:nil];
    [[CoreDataManager sharedInstance] setCreatingGRN:YES];
    self.poLabel.text = [NSString stringWithFormat:@"Order Items for %@",self.grn.purchaseOrder.orderNumber];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (IBAction)next:(id)sender {
    NSMutableString *errorString = [[NSMutableString alloc] init];
    if (![self stripedTextLength:self.sdn.text])
    {
        [errorString appendFormat:@"Please enter a valid Supplier Reference Number (SDN).\n"];
    }
    else if ([SDN doesSDNExist:self.sdn.text inMOC:[CoreDataManager moc]])
    {
        [errorString appendFormat:@"A GRN with this Service Delivery Number has already been submitted. Please enter a different SDN.\n"];
    }
    else
    {
        self.grn.supplierReference = self.sdn.text;
    }
    //Check all line items
    for (GRNItem *lineItem in self.grn.lineItems)
    {
        if ([lineItem.quantityRejected doubleValue] > [lineItem.quantityDelivered doubleValue])
        {
            [errorString appendFormat:@"Rejected ￼quantity for item must not exceed the quantity ￼delivered.\n"];
            break;
        }
    }
    if (errorString.length)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorString
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self performSegueWithIdentifier:@"completeGRN" sender:self];
    }
}
- (IBAction)acceptOrClear:(UIButton*)sender
{
    BOOL accept = [sender.titleLabel.text hasPrefix:@"Accept"];
    for (GRNItem *li in self.grn.lineItems)
    {
        li.quantityDelivered = accept? li.purchaseOrderItem.quantityBalance : [NSNumber numberWithInt:0];
        NSLog(@"%@,%@",li.quantityDelivered, li.purchaseOrderItem);
    }
    [sender setTitle:accept? @"Clear All" : @"Accept All" forState:UIControlStateNormal];
    [self.tableView reloadData];
}

- (IBAction)back:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to discard this GRN?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",nil];
    [alert show];
    
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
    GRNItem *grnItem = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@ [%.02f of %.02f %@]",
                           grnItem.purchaseOrderItem.itemNumber,
                           grnItem.purchaseOrderItem.itemDescription,
                           [grnItem.quantityDelivered doubleValue],
                           [grnItem.purchaseOrderItem.quantityBalance doubleValue],
                           grnItem.purchaseOrderItem.uoq];
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
    else
    {
        cell.selected = NO;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.selectedIndexPath)
//    {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
//        cell.selected = NO;
//        [tableView deselectRowAtIndexPath:self.selectedIndexPath animated:NO];
//        //        [tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//        self.selectedIndexPath = indexPath;
//    }
//
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"itemDetails" sender:self];
}

-(NSArray*)dataArray
{
    if(!_dataArray)
    {
        _dataArray = [self.grn.lineItems allObjects];
    }
    return _dataArray;
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setSdn:nil];
    [self setPoLabel:nil];
    [super viewDidUnload];
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    @try {
        if ([textField isEqual:self.sdn])
        {
            if (![SDN doesSDNExist:textField.text inMOC:[CoreDataManager moc]])
            {
                self.grn.supplierReference = textField.text;
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"A GRN with this Service Delivery Number has already been submitted."
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    @catch (NSException *exception) {
        //This happens when we go back and there is no grn
    }
    
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSManagedObjectContext *moc = [CoreDataManager moc];
        for (GRNItem *i in self.grn.lineItems)
        {
            [moc deleteObject:i];
        }
        [moc deleteObject:self.grn];
        [moc save:nil];
        
        //Remove data from nsuserdefaults
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:nil forKey:KeyImage1];
        [defaults setObject:nil forKey:KeyImage2];
        [defaults setObject:nil forKey:KeyImage3];
        [defaults setObject:nil forKey:KeySignature];
        [defaults synchronize];
        [[CoreDataManager sharedInstance] setCreatingGRN:NO];

        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"itemDetails"])
    {
        GRNOrderItemDetailViewController *vc = segue.destinationViewController;
        vc.grnItem = [self.dataArray objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
    else if ([segue.identifier isEqualToString:@"completeGRN"])
    {
        //Save items
        [[CoreDataManager moc] save:nil];
        GRNCompleteGrnViewController *vc = segue.destinationViewController;
        vc.grn = self.grn;
    }
}


-(int)stripedTextLength:(NSString*)text
{
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length;
}

@end
