//
//  PopViewControllerSegue.m
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "PopViewControllerSegue.h"

@implementation PopViewControllerSegue

-(void)perform
{
    [[(UIViewController*)self.sourceViewController navigationController] popViewControllerAnimated:YES];
}

@end
