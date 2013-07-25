//
//  PhotoPreviewVC.m
//  mGRN
//
//  Created by Anum on 08/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "PhotoPreviewVC.h"

@implementation PhotoPreviewVC

- (IBAction)close:(id)sender {
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (self.image.imageOrientation == UIImageOrientationLeft || self.image.imageOrientation == UIImageOrientationRight)
//    {
//        self.imageView.transform = CGAffineTransformMakeRotation(M_PI/2);
//    }
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = self.image;
}

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
