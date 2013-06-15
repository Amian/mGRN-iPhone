//
//  GRNMasterViewController.h
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GRNDetailViewController;

#import <CoreData/CoreData.h>

@interface GRNMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) GRNDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
