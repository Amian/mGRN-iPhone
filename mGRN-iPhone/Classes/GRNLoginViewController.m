//
//  GRNLoginViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNLoginViewController.h"
#import "LoadingView.h"
#import "M1X.h"
#import "GRNM1XHeader.h"
#import "CoreDataManager.h"

#define mGRNLogoCenter CGPointMake(160.0, 100.0);


@interface GRNLoginViewController () <M1XDelegate, UITextFieldDelegate>
{
    BOOL animationInProgress;
    BOOL keyboardVisible;
}
@property (nonatomic, strong) LoadingView *loadingView;
@end

@implementation GRNLoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    
    self.username.text = AmIBeingDebugged()? @"chaamu" : @"";
    self.password.text = AmIBeingDebugged()? @"cham" : @"";
    
    self.hiddenView.alpha = 0.0;
    self.mgrnLogo.alpha = 1.0;
    self.mgrnLogo.center = self.hiddenView.center;
    
    [self.view addSubview:self.loadingView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![[userDefault objectForKey:KeyDomainName] length] ||
        ![userDefault objectForKey:KeySystemURI])
    {
        [self performSegueWithIdentifier:@"settings" sender:self];
        return;
    }
    [self animationPartOne];
}

- (void)viewDidUnload {
    [self setHiddenView:nil];
    [self setUsername:nil];
    [self setPassword:nil];
    [self setMgrnLogo:nil];
    [super viewDidUnload];
}


#pragma mark - IB Actions

-(IBAction)login
{
    if (!self.username.text.length || !self.password.text.length)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter username and password."
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self earthquake:self.hiddenView];
        return;
    }
        self.loadingView.hidden = NO;
    
    //Give loading view time to appear
    [self performSelector:@selector(createNewSession) withObject:nil afterDelay:0.1];
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}


#pragma mark - Animation

-(void)animationPartOne
{
    animationInProgress = YES;
    [self performSelector:@selector(animationPartTwo) withObject:nil afterDelay:0.7];
}

-(void)animationPartTwo
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.mgrnLogo.alpha = 0.0;
    [UIView commitAnimations];
    [self performSelector:@selector(animationPartThree) withObject:nil afterDelay:0.3];
}

-(void)animationPartThree
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    self.hiddenView.alpha = 1.0;
    [UIView commitAnimations];
    [self performSelector:@selector(animationPartFour) withObject:nil afterDelay:1.0];
}

-(void)animationPartFour
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    self.mgrnLogo.alpha = 1.0;
    self.mgrnLogo.center = mGRNLogoCenter;
    [UIView commitAnimations];
    [self performSelector:@selector(animationComplete) withObject:nil afterDelay:2.0];
}

-(void)animationComplete
{
    animationInProgress = NO;
}

#pragma mark - Earthquake

- (void)earthquake:(UIView*)itemView
{
    CGFloat t = 2.0;
    
    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, -t);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, t);
    
    itemView.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void *)(itemView)];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:5];
    [UIView setAnimationDuration:0.07];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    itemView.transform = rightQuake; // end here & auto-reverse
    
    [UIView commitAnimations];
}

- (void)earthquakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue])
    {
        UIView* item = (__bridge UIView *)context;
        item.transform = CGAffineTransformIdentity;
    }
}

#pragma mark - Session methods and M1X Delegate

-(void)createNewSession
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    M1XRequestHeader *header = [[M1XRequestHeader alloc] init];
    header.userId = self.username.text;
    header.password = self.password.text;
    header.domain = [userDefault objectForKey:KeyDomainName];
    header.role = GRNRole;
    header.transactionId = [[NSProcessInfo processInfo] globallyUniqueString];
    
    //Save session values
    [userDefault setValue:header.transactionId forKey:KeyTransactionID];
    [userDefault setValue:header.role forKey:KeyRole];
    [userDefault synchronize];
    
    M1X *m1x = [[M1X alloc] init];
    m1x.delegate = self;
    [m1x newSessionForAppName:GRNAppName withHeader:header];
}

-(void)onNewSessionSuccess:(M1XSession *)session
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:session.userId forKey:KeyUserID];
    [userDefault setValue:session.sessionEndDT forKey:KeySessionEndDate];
    [userDefault setValue:session.sessionKey forKey:KeyPassword];
    [userDefault setValue:session.kco forKey:KeyKCO];
    [userDefault synchronize];
    
    M1XRequestHeader *header = [GRNM1XHeader Header];
    M1X *m1x = [[M1X alloc] init];
    m1x.delegate = self;
    [m1x FetchServiceConnectionDetailsForAppName:GRNAppName withHeader:header];
    
}


-(void)onServiceConnectionSuccess:(M1XServiceConnection *)service
{
    if (!service.port.length || !service.server.length || !service.serviceName.length)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exception"
                                                        message:@"Could not retrieve service connection details."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:service.port forKey:KeyServicePort];
    [userDefault setValue:service.server forKey:KeyServiceServer];
    [userDefault setValue:service.serviceName forKey:KeyServiceName];
    [userDefault synchronize];
    
    [self initialSetup];
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    [self performSegueWithIdentifier:@"login" sender:nil];
    [self.loadingView setHidden:YES];
}

-(void)onNewSessionFailure:(M1XResponse *)response exceptionType:(M1xException)exception
{
    [self.loadingView setHidden:YES];
    [self earthquake:self.hiddenView];
    if (exception != 0)
    {
        NSString *message = @"";
        switch (exception)
        {
            case M1xExceptionAuthenticationFailed:
            {
                message = @"Authentication has failed. Please try a different ￼username/password.";
                break;
            }
            case M1xExceptionNoSuccess:
            {
                message = @"Unable to connect to server.";
                break;
            }
            case M1xExceptionNoInternetConnection:
                break;
            case M1xExceptionNone:
            default:
                message = @"Unknown exception.";
                break;
        }
        if (message.length)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exception"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}


-(void)initialSetup
{
    //TODO:[SDN removeExpiredSDNinMOC:[CoreDataManager moc]];
    /*if (!AmIBeingDebugged())*/ [CoreDataManager removeAllContractData];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:KeyImage1];
    [defaults setValue:nil forKey:KeyImage2];
    [defaults setValue:nil forKey:KeyImage3];
    [defaults setValue:nil forKey:KeySignature];
    [defaults synchronize];
    [[CoreDataManager sharedInstance] startSession];
}


-(void)onKeyboardHide:(NSNotification *)notification
{
    keyboardVisible = NO;
    [self adjustViewForKeyboard];
}

-(void)onKeyboardShow:(NSNotification *)notification
{
    keyboardVisible = YES;
    [self adjustViewForKeyboard];
}

-(void)adjustViewForKeyboard
{
    CGRect rect = self.view.bounds;
    rect.origin.y = keyboardVisible? 100.0 : 0.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.view.bounds = rect;
    [UIView commitAnimations];
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.username])
    {
        [self.password becomeFirstResponder];
        return NO;
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Properties


-(UIView*)loadingView
{
    if(!_loadingView)
    {
        _loadingView = [[LoadingView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_loadingView];
        _loadingView.hidden = YES;
    }
    return _loadingView;
}


@end
