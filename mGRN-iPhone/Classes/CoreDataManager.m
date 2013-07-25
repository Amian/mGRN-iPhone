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
//        self.timeInterval = DefaultSubmissionTimeInterval;
//        self.dataIsBeingRemoved = NO;
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

+(void)removeData:(BOOL)allData
{
    //TODO: implement
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
}

-(void)submitGRN
{
    //TODO:
}

+(NSManagedObjectContext*)moc
{
    return [(GRNAppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
}

+(BOOL)hasSessionExpired
{
    //TODO:
    return NO;
}

#pragma mark - GRN Submission

-(void)submitAnyGrnsAwaitingSubmittion
{
    //TODO:
}
@end
