//
//  GRNContractsViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//


#import "GRNContractsViewController.h"
#import "Contract+Management.h"
#import "CoreDataManager.h"
#import "M1XmGRNService.h"
#import "GRNM1XHeader.h"
#import "GRNPurchaseOrderViewController.h"
#import "RejectionReasons+Management.h"
#import "WBS+Management.h"

@interface GRNContractsViewController ()
@end

@implementation GRNContractsViewController

-(void)viewDidUnload
{
    self.service.delegate = nil;
}

- (void)viewDidLoad
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.dataArray = [Contract fetchAllContractsInManagedObjectContext:[CoreDataManager moc]];
        if (!self.dataArray.count)
        {
            [self getDataFromAPI];
        }
        else
        {
            [self.tableView reloadData];
        }
    }];
    [super viewDidLoad];
}

#pragma mark - Table Data Source

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.indentationLevel = 1;
        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:18.0];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Contract *contract = [self.dataArray objectAtIndex:indexPath.section];
    cell.textLabel.text = contract.number;
    cell.detailTextLabel.text = contract.name;
    
    return cell;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0;
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"purchaseOrders" sender:self];
}

#pragma mark - Getting Data

-(void)getDataFromAPI
{
    if ([CoreDataManager hasSessionExpired])
    {
        //TODO
        return;
    }
    [self startLoading];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [CoreDataManager removeAllContractData];
        [self.service GetContractsWithHeader:[GRNM1XHeader Header] kco:self.kco includeWBS:NO];
    }];
}

-(void)onAPIRequestSuccess:(NSDictionary *)response requestType:(RequestType)requestType
{
    if (requestType == RequestTypeGetContracts)
    {
        //    NSLog(@"response = %@",contractData);
        NSManagedObjectContext *context = [CoreDataManager moc];
        NSError *error = NULL;
        NSArray *contracts = [response objectForKey:@"contracts"];
        NSMutableArray *contractObjectArray = [NSMutableArray array];
        if (contracts.count)
        {
            [CoreDataManager removeData:NO];
        }
        for (NSDictionary *dict in contracts)
        {
            Contract *c = [Contract insertContractWithData:dict
                                    inManagedObjectContext:context
                                                     error:&error];
            [contractObjectArray addObject:c];
        }
        [context save:nil];
        self.dataArray = [self getDataArray];
        [self.tableView reloadData];
        if (![[RejectionReasons getAllRejectionReasonsInMOC:[CoreDataManager moc]] count])
            [self getReasonsFromAPI];
        else
            [self stopLoading];
    }
    else if (requestType == RequestTypeRejectionReason)
    {
        NSArray *reasons = [response objectForKey:@"reasons"];
        for (NSDictionary *r in reasons)
        {
            [RejectionReasons insertRejectionReasonsWithDictionary:r inMOC:[CoreDataManager moc]];
        }
        [self stopLoading];
    }
    else
    {
        [self stopLoading];
    }
}

-(void)onAPIRequestFailure:(M1XResponse *)response
{
    [self stopLoading];
}

-(NSArray*)getDataArray
{
    NSArray *array = [Contract fetchAllContractsInManagedObjectContext:[CoreDataManager moc]];
    return array;
}



#pragma mark - IB Actions





#pragma mark - Segue

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"purchaseOrders"] && [CoreDataManager hasSessionExpired])
    {
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"purchaseOrders"])
    {
        GRNPurchaseOrderViewController *pvc = segue.destinationViewController;
        pvc.contract = [self.dataArray objectAtIndex:self.selectedIndex.section];
    }
}


//TODO:Search

#pragma mark - Search

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchString
{
    if (searchString.length)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number CONTAINS[c] %@ OR name CONTAINS[c] %@",searchString,searchString];
        self.dataArray = [[self getDataArray] filteredArrayUsingPredicate:predicate];
    }
    else
    {
        self.dataArray = [self getDataArray];
    }
    [self.tableView reloadData];
}

-(void)getReasonsFromAPI
{
    M1XmGRNService *service = [[M1XmGRNService alloc] init];
    service.delegate = self;
    NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
    kco = [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
    [service GetRejectionReasonsWithHeader:[GRNM1XHeader Header]
                                       kco:kco];
}

@end
