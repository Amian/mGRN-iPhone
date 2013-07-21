//
//  GRNBaseViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNBaseViewController.h"
#import "CoreDataManager.h"

@interface GRNBaseViewController ()
@property (nonatomic, strong) UIView *loadingView;
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
    self.tableView.frame = CGRectMake(14.0, 44.0, 292.0, 504.0);
}

-(void)onKeyboardShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue]; //height of keyboard
    self.tableView.frame = CGRectMake(14.0, 44.0, 292.0, 504.0 - keyboardFrame.size.height);
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
    //TODO:LoadingView
    self.state = TableStateNormal;
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

-(IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
        [CoreDataManager removeData:NO];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:GRNLightBlueColour];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
//    if (self.state == TableStateSelected && indexPath.section != self.tableView.indexPathForSelectedRow.section)
//    {
//        cell.alpha = 0.4;
//    }
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
