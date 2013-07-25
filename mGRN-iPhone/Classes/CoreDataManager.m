//
//  CoreDataManager.m
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "CoreDataManager.h"
#import "GRNAppDelegate.h"
#import "WBS+Management.h"
#import "PurchaseOrder+Management.h"
#import "PurchaseOrderItem+Management.h"
#import "Contract+Management.h"
#import "RejectionReasons+Management.h"
#import "SDN+Management.h"
#import "WBS+Management.h"
#import "GRN+Management.h"
#import "Reachability.h"
#import "M1XmGRNService.h"
#import "GRNM1XHeader.h"
#import "GRNItem+Management.h"

#define DefaultSubmissionTimeInterval 60.0
#define SessionExpiryTimeInterval (AmIBeingDebugged()? 330.0 : 18.0 * 3600.0)
#define SessionExpiryWarningTimeInterval (AmIBeingDebugged()? SessionExpiryTimeInterval - 5.0 : SessionExpiryTimeInterval - 10.0 * 60.0)

@interface CoreDataManager() <M1XmGRNDelegate>
{
    BOOL alreadyWaitingForInternetConnection;
    BOOL alreadyProcessingGrns;
}
@property BOOL sessionExpired;
@property (nonatomic, strong) NSOperationQueue *submissionQueue;
@property float timeInterval;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, strong) UIAlertView *warningAlert;

@end;

@implementation CoreDataManager

static CoreDataManager *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (CoreDataManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.timeInterval = DefaultSubmissionTimeInterval;
        self.internetReach = [Reachability reachabilityForInternetConnection];
        [self.internetReach startNotifier];
    }
    
    return self;
}


// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

+(void)removeAllAppData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:KeyUserID];
    [defaults setObject:nil forKey:KeyPassword];
    [defaults setObject:nil forKey:KeyTransactionID];
    [defaults setObject:nil forKey:KeySessionEndDate];
    [defaults synchronize];
    
    NSManagedObjectContext *context = [CoreDataManager moc];
    [SDN removeAllSDNsinMOC:context];
    [GRN removeAllObjectsInManagedObjectContext:context];
    
    [CoreDataManager removeAllContractData];
}

+(void)removeAllContractData
{
    //TODO: implement
    NSManagedObjectContext *context = [CoreDataManager moc];
    [Contract removeAllContractsInManagedObjectContext:context];
    [PurchaseOrder removeAllPurchaseOrdersInManagedObjectContext:context];
    [PurchaseOrderItem removeAllPurchaseOrdersItemsInManagedObjectContext:context];
    [WBS removeAllWBSInManagedObjectContext:context];
    [RejectionReasons removeAllRejectionReasonsInMOC:context];
    [context save:nil];
}

-(NSManagedObjectContext*)managedObjectContext
{
    if (!_managedObjectContext)
    {
        _managedObjectContext = [(GRNAppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    }
    return _managedObjectContext;
}

+(NSManagedObjectContext*)moc
{
    return [[CoreDataManager sharedInstance] managedObjectContext];
}

+(NSManagedObjectContext*)NewManagedObjectContext
{
    GRNAppDelegate *delegate = (GRNAppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator: [delegate persistentStoreCoordinator]];
    return context;
}

-(NSOperationQueue*)submissionQueue
{
    if (!_submissionQueue)
    {
        _submissionQueue = [[NSOperationQueue alloc] init];
        [_submissionQueue setName:@"SubmissionQueue"];
    }
    return _submissionQueue;
}



#pragma mark - GRN Submission

-(void)submitAnyGrnsAwaitingSubmittion
{
    if ([self areThereAnyGrnAwaitingSubmission])
    {
        if ([self internetConnectionIsAvailable])
        {
            [self submitGrns];
        }
        else if (!alreadyWaitingForInternetConnection)
        {
            //Be notified when connection becomes available
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(reachabilityChanged:)
                                                         name: kReachabilityChangedNotification
                                                       object: nil];
            alreadyWaitingForInternetConnection = YES;
        }
    }
    else
    {
        self.timeInterval = DefaultSubmissionTimeInterval;
    }
}

-(BOOL)areThereAnyGrnAwaitingSubmission
{
    return [GRN CountGrnAwaitingSubmissionInMOC:self.managedObjectContext] > 0? YES : NO;
}

-(BOOL)internetConnectionIsAvailable
{
    return [self.internetReach currentReachabilityStatus] == 0? NO : YES;
}

- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus)
    {
        case ReachableViaWWAN:
        case ReachableViaWiFi:
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
            alreadyWaitingForInternetConnection = NO;
            [self submitGrns];
            break;
        }
        case NotReachable:
        {
            
            break;
        }
    }
}

-(void)submitGrns
{
    alreadyProcessingGrns = YES;
    NSOperationQueue *myQueue = self.submissionQueue;
    [myQueue addOperationWithBlock:^{
        NSManagedObjectContext *context = [CoreDataManager NewManagedObjectContext];
        NSArray *allGRNs = [GRN fetchSubmittedGRNInMOC:context];
        for (GRN *grn in allGRNs)
        {
            if (![self internetConnectionIsAvailable]) break;
            bool success = [self submit:grn];
            if (!success)
            {
                //This happens in case of an m1xException.
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.timeInterval = self.timeInterval *2;
                    [self performSelector:@selector(submitAnyGrnsAwaitingSubmittion)
                               withObject:nil
                               afterDelay:self.timeInterval];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        [self.managedObjectContext save:nil];
                        alreadyProcessingGrns = NO;
                    }];
                    NSLog(@"Try to submit GRNs again after time= %f",self.timeInterval);
                }];
                return;
            }
        }
        //In case any grns were submitted while queue was busy check for grns again
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.managedObjectContext save:nil];
            alreadyProcessingGrns = NO;
            [self submitAnyGrnsAwaitingSubmittion];
        }];
    }];
}

- (BOOL)submit:(GRN*)newGRN
{
    M1XmGRNService *service = [[M1XmGRNService alloc] init];
    //    service.delegate = self;
    NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
    @try
    {
        kco = [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
    }
    @catch (NSException *ex)
    {
        //
    }
    M1XGRN *grn = [[M1XGRN alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'00:00:00";
    grn.deliveryDate = [formatter stringFromDate:newGRN.deliveryDate];
    

    
    grn.kco = kco;
    grn.notes = newGRN.notes;
    grn.orderNumber = newGRN.orderNumber;
    grn.photo1 = newGRN.photo1URI;
    grn.photo2 = newGRN.photo2URI;
    grn.photo3 = newGRN.photo3URI;
    grn.signature = newGRN.signatureURI;
    grn.supplierReference = newGRN.supplierReference;
    NSMutableArray *items = [NSMutableArray array];
    for (GRNItem *item in newGRN.lineItems)
    {
        M1XLineItems *newItem = [[M1XLineItems alloc] init];
        newItem.exception = item.exception.length? item.exception : @"";
        newItem.item = item.itemNumber;
        newItem.notes = item.notes;
        newItem.quantityDelivered = [NSString stringWithFormat:@"%f",[item.quantityDelivered doubleValue]];
        newItem.quantityRejected = [NSString stringWithFormat:@"%f",[item.quantityRejected doubleValue]];
        newItem.serialNumber = item.serialNumber;
        newItem.unitOfQuantityDelivered = item.uoq;
        newItem.wbsCode = item.wbsCode;
        [items addObject:newItem];
    }
    
    M1XResponse *result = [service DoSubmissionSyncWithHeader:[GRNM1XHeader Header]
                                                          grn:grn
                                                    lineItems:items
                                                          kco:kco];
    bool returnValue = result.header.success;
    if (result.header.success)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            @try {
                NSManagedObjectContext *context = [CoreDataManager moc];
                [context deleteObject:[context objectWithID:[newGRN objectID]]];
            }
            @catch (NSException *exception) {
                NSLog(@"Already deleted");
                //Already deleted
            }
        }];
    }
    else
    {
        //Check if it is m1x exception or coins exception
        if (result.header.exception && [result.header.exception.source rangeOfString:@"Coin"].location != NSNotFound)
        {
            //If it is a coins exception ignore
            returnValue = YES;
        }
    }
    NSLog(@"Response header = %@",result.header.description);
    NSLog(@"Response body = %@",result.body);
    return result.header.success;
}

#pragma mark - Session Management

-(void)startSession
{
    self.sessionExpired = NO;
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
//    NSDate *expiryDate = [formatter dateFromString:[defaults objectForKey:KeySessionEndDate]];
    [[CoreDataManager sharedInstance] performSelector:@selector(sessionWarining)
               withObject:nil
               afterDelay:SessionExpiryWarningTimeInterval];
    
    [[CoreDataManager sharedInstance] performSelector:@selector(onSessionExpiry)
               withObject:nil
               afterDelay:SessionExpiryTimeInterval];
}


-(void)sessionWarining
{
//    self.warningAlert = [[UIAlertView alloc] initWithTitle:@"You session will expire in 10 minutes. Please log out and log in again to continue using the application."
//                                                   message:nil
//                                                  delegate:nil
//                                         cancelButtonTitle:@"OK"
//                                         otherButtonTitles:nil];
//    [self.warningAlert show];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You session will expire in 10 minutes. Please log out and log in again to continue using the application."
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
//    [alert performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:4.0];
}

-(void)onSessionExpiry
{
    self.sessionExpired = YES;
//    [[NSNotificationCenter defaultCenter] postNotificationName:SessionExpiryNotification
//                                                        object:nil];
//    [self.warningAlert removeFromSuperview];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[self sessionExpiryText]
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)endSession
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sessionWarining) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onSessionExpiry) object:nil];
}

-(NSString*)sessionExpiryText
{
    if (self.creatingGRN)
    {
        return SessionExpiryDuringGRNText;
    }
    else
    {
        return SessionExpiryText;
    }
}

+(BOOL)hasSessionExpired
{
    return [[CoreDataManager sharedInstance] sessionExpired];
}
@end
