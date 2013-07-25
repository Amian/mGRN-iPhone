//
//  CoreDataManager.h
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject
+ (CoreDataManager*)sharedInstance;
//-(void)submitGRN;
+(NSManagedObjectContext*)moc;
+(BOOL)hasSessionExpired;
+(void)removeAllAppData;
+(void)removeAllContractData;
-(void)submitAnyGrnsAwaitingSubmittion;
-(void)startSession;
-(void)endSession;
@property BOOL creatingGRN;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
