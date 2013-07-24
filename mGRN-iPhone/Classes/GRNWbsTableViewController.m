//
//  GRNWbsTableViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 24/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNWbsTableViewController.h"
#import "WBS+Management.h"
#import "CoreDataManager.h"

@interface GRNWbsTableViewController ()
@end

@implementation GRNWbsTableViewController


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
    WBS *wbs = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",wbs.code,wbs.codeDescription];
//    if ([wbs.code isEqualToString:self.selectedWbsCode])
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
    WBS *wbs = [self.dataArray objectAtIndex:indexPath.row];
    if ([wbs.code isEqualToString:self.selectedWbsCode])
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
    [[self delegate] wbsSelected:[self.dataArray objectAtIndex:indexPath.row]];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
