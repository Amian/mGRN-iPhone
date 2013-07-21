//
//  LoadingView.m
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@interface LoadingView()
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIView *grayView;

@end

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialise];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self initialise];
    }
    return self;
}

-(void)initialise
{
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    [self.grayView addSubview:self.activityIndicator];
    self.activityIndicator.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
    self.activityIndicator.center = CGPointMake(self.grayView.bounds.size.width/2, self.grayView.bounds.size.height/2);
    [self.activityIndicator startAnimating];
    self.grayView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self addSubview:self.grayView];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.grayView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

-(UIActivityIndicatorView*)activityIndicator
{
    if (!_activityIndicator)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _activityIndicator;
}

-(UIView*)grayView
{
    if (!_grayView)
    {
        self.grayView = [[UIView alloc] init];
        self.grayView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
        self.grayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
        self.grayView.layer.cornerRadius = 5.0;
        self.grayView.layer.borderColor = [UIColor blackColor].CGColor;
        self.grayView.layer.borderWidth = 2.0;
        self.grayView.clipsToBounds = YES;

    }
    return _grayView;
}

@end
