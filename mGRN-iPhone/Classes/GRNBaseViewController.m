//
//  GRNBaseViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNBaseViewController.h"
#import "CoreDataManager.h"
#import "RejectionReasons+Management.h"
#import "GRNM1XHeader.h"

#define SearchCancelButtonTag 101

@interface GRNBaseViewController ()
@property (nonatomic, strong) UIView *loadingView;
@property CGRect tableViewFrame;
@end

@implementation GRNBaseViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Enable cancel button
    for (UIView *possibleButton in self.searchBar.subviews)
    {
        if ([possibleButton isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton*)possibleButton;
            cancelButton.tag = SearchCancelButtonTag;
            cancelButton.enabled = YES;
            break;
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    //Notify when keyboard appears
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    
    
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


#pragma mark - Keyboard Notifications

-(void)onKeyboardHide:(NSNotification *)notification
{
    self.tableView.frame = self.tableViewFrame;
}

-(void)onKeyboardShow:(NSNotification *)notification
{
    self.tableViewFrame = self.tableView.frame;
    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue]; //height of keyboard
    CGRect frame = self.tableViewFrame;
    frame.size.height -= keyboardFrame.size.height;
    self.tableView.frame = frame;
}

#pragma makr - Getters and Setters

-(M1XmGRNService*)service
{
    if (!_service)
    {
        _service = [[M1XmGRNService alloc] init];
        _service.delegate = self;
    }
    return _service;
}


-(NSString*)kco
{
    NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
    return [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
}

- (IBAction)logout:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to log out?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES",nil];
    [alert show];
}

- (IBAction)reloadData:(id)sender
{
    if ([CoreDataManager hasSessionExpired])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SessionExpiryText
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    self.selectedIndex = nil;
    [self getDataFromAPI];
}


- (IBAction)showInfo:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *info = [NSString stringWithFormat:@"Username: %@\nMaster Host: %@\nDomain: %@\nVersion: %@",
                      [defaults objectForKey:KeyUserID],[defaults objectForKey:KeySystemURI],[defaults objectForKey:KeyDomainName],[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]];
    //    self.infoLabel.text = info;
    //    self.infoView.frame = self.view.bounds;
    //    [self.view addSubview:self.infoView];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:info
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)getDataFromAPI
{
    //Override
}

- (IBAction)search:(id)sender
{
    self.searchBar.text = @"";
    self.searchBar.hidden = NO;
    [self.searchBar becomeFirstResponder];
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        //Logout
        [[CoreDataManager sharedInstance] endSession];
        [CoreDataManager removeAllContractData];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:GRNLightBlueColour];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    if (self.selectedIndex && indexPath.section != self.selectedIndex.section)
    {
        cell.alpha = 0.4;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath;
    [self.tableView reloadData];
}

//-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    return nil;
////    return [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 5.0)];
//}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 5.0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.dataArray = [self getDataArray];
    [self.tableView reloadData];
    self.searchBar.hidden = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [(UIButton*)[self.searchBar viewWithTag:SearchCancelButtonTag] setEnabled:YES];
}

-(NSArray*)getDataArray
{
    //OVERRIDE
    return nil;
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
