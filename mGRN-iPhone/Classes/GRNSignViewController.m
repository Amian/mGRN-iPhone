//
//  GRNSignViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 24/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNSignViewController.h"
#import "DrawView.h"
#import <QuartzCore/QuartzCore.h>

@interface GRNSignViewController () <DrawViewDelegate>
@property (nonatomic, strong) UIImageView *fakeSignature;
@end

@implementation GRNSignViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UIImage *fakeImage = [UIImage imageWithData:[defaults objectForKey:KeySignature]];
    if (fakeImage)
    {
        self.fakeSignature = [[UIImageView alloc] initWithFrame:self.signatureView.bounds];
        self.fakeSignature.image = fakeImage;
        self.fakeSignature.userInteractionEnabled = NO;
        [self.signatureView addSubview:self.fakeSignature];
        self.fakeSignature.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
    self.signatureView.delegate = self;
    self.signatureView.superview.layer.borderColor = [UIColor orangeColor].CGColor;
    self.signatureView.superview.layer.borderWidth = 1.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signAgain:(id)sender
{
    self.signagainbutton.enabled = NO;
    [self.fakeSignature removeFromSuperview];
    [self.signatureView clearView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void)
                   {
                       
                       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                       [defaults setValue:nil forKey:KeySignature];
                       [defaults synchronize];
                   });
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void)
                   {
                       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                       if (self.signatureView.hasSigned)
                       {
                           [defaults setValue:UIImagePNGRepresentation([self.signatureView makeImage]) forKey:KeySignature];
                           [defaults synchronize];
                       }
                   });
}

-(void)drawViewDidBeginDrawing
{
    self.signagainbutton.enabled = YES;
    [self.fakeSignature removeFromSuperview];
}

-(void)drawViewDidEndDrawing
{
}
- (void)viewDidUnload {
    [self setSignagainbutton:nil];
    [super viewDidUnload];
}
@end
