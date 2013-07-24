//
//  GRNRejectionReasonTableViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 24/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNRejectionReasonTableViewController.h"
#import "RejectionReasons+Management.h"
#import "CoreDataManager.h"
@interface GRNRejectionReasonTableViewController ()
@property (nonatomic, retain) NSArray *dataArray;
@end

@implementation GRNRejectionReasonTableViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *MyIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        cell.indentationLevel = 1;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    RejectionReasons *reason = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = reason.codeDescription;
//    if ([reason.code isEqualToString:self.selectedReasonCode])
//    {
//        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
//    }
//    else
//    {
//        [cell setAccessoryType:UITableViewCellAccessoryNone];
//    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RejectionReasons *reason = [self.dataArray objectAtIndex:indexPath.row];
    if ([reason.code isEqualToString:self.selectedReasonCode])
    {
        cell.selected = YES;
    }
    else
    {
        cell.selected = NO;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self delegate] RejectionReasonDidSelectReason:[self.dataArray objectAtIndex:indexPath.row]];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(NSArray*)dataArray
{
    if (!_dataArray)
    {
        _dataArray = [RejectionReasons getAllRejectionReasonsInMOC:[CoreDataManager moc]];
    }
    return _dataArray;
}
@end
