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
+(void)removeData:(BOOL)allData;
-(void)submitGRN;
+(NSManagedObjectContext*)moc;
+(BOOL)hasSessionExpired;
+(void)removeAllContractData;
@end
