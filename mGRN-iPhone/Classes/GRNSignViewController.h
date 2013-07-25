//
//  GRNSignViewController.h
//  mGRN-iPhone
//
//  Created by Anum on 24/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DrawView;
@interface GRNSignViewController : UIViewController
@property (strong, nonatomic) IBOutlet DrawView *signatureView;

- (IBAction)signAgain:(id)sender;
@end
