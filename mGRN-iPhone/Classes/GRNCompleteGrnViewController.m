//
//  GRNCompleteGrnViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 24/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNCompleteGrnViewController.h"
#import "GRN+Management.h"
#import <QuartzCore/QuartzCore.h>

@interface GRNCompleteGrnViewController ()
@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;
@property (nonatomic, strong) UIImage *image3;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIView *datePickerView;
@end

@implementation GRNCompleteGrnViewController

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

-(void)displayGRN
{
    if (self.grn.deliveryDate)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd/MM/yyyy";
        NSString *date = [formatter stringFromDate:self.grn.deliveryDate];
        [self.dateButton setTitle:date forState:UIControlStateNormal];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.image1 = [UIImage imageWithData:[defaults objectForKey:KeyImage1]];
    self.image2 = [UIImage imageWithData:[defaults objectForKey:KeyImage2]];
    self.image3 = [UIImage imageWithData:[defaults objectForKey:KeyImage3]];
    [self refreshImageView];

    //Remove data from nsuserdefaults
    [defaults setObject:nil forKey:KeyImage1];
    [defaults setObject:nil forKey:KeyImage2];
    [defaults setObject:nil forKey:KeyImage3];
    [defaults synchronize];

}


-(void)refreshImageView
{
    [self.photoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    int i = 0;
    if (self.image1)
    {
        [self displayImage:self.image1 position:i tag:1];
        i++;
    }
    if(self.image2)
    {
        [self displayImage:self.image2 position:i tag:2];
        i++;
    }
    if(self.image3)
    {
        [self displayImage:self.image3 position:i tag:3];
        i++;
    }
    self.takePhotoButton.enabled = i == 3? NO :YES;
}

-(void)displayImage:(UIImage*)image position:(int)position tag:(int)tag
{
    //calculate width
    CGFloat h = (self.photoView.frame.size.width - 10.0*3)/3;
    CGFloat w = self.photoView.frame.size.height *5/6;
    CGFloat width = h > w? w : h;
    
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    int x = self.photoView.subviews.count/2;
    imageButton.frame = CGRectMake(width*position + 10.0*position, 0.0, width, width);
    [imageButton setImage:image forState:UIControlStateNormal];
    imageButton.imageView.contentMode = UIViewContentModeScaleToFill;
    imageButton.tag = tag;
    imageButton.backgroundColor = [UIColor clearColor];
    [imageButton addTarget:self
                    action:@selector(previewImage:)
          forControlEvents:UIControlEventTouchUpInside];
    imageButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.photoView addSubview:imageButton];
    
    UIButton *delete = [UIButton buttonWithType:UIButtonTypeCustom];
    delete.backgroundColor = GRNDarkBlueColour;
    delete.tag = tag;
    [delete setImage:[UIImage imageNamed:@"11-x.png"] forState:UIControlStateNormal];
    delete.imageView.contentMode = UIViewContentModeScaleAspectFit;
    delete.frame = CGRectMake(width*x + 10.0*x, width, width, width/5);
    [delete addTarget:self
               action:@selector(deletePhoto:)
     forControlEvents:UIControlEventTouchUpInside];
    delete.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.photoView addSubview:delete];
}

-(void)deletePhoto:(UIButton*)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to remove this photo?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    alert.tag = sender.tag;
    [alert show];
}


- (NSString*)base64forData:(NSData*)theData {
    
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (IBAction)showDatePicker:(UIButton*)button
{
    self.datePickerView.hidden = NO;
}


-(void)donePickingDate:(UIDatePicker*)picker
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd/MM/yyyy";
    NSString *date = [formatter stringFromDate:picker.date];
    [self.dateButton setTitle:date forState:UIControlStateNormal];
    self.grn.deliveryDate = picker.date;
}

-(void)removeDatePicker
{
    self.dateButton.superview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.datePickerView.hidden = YES;
}

-(UIView*)datePickerView
{
    if (!_datePickerView)
    {
    _datePickerView = [[UIView alloc] init];   //view
    
    UIDatePicker *datePicker=[[UIDatePicker alloc]init];//Date picker
    datePicker.frame=CGRectMake(0,44,320, 216);
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setMinuteInterval:5];
    [datePicker setMaximumDate:[NSDate date]];
    [datePicker setTag:10];
    [datePicker addTarget:self action:@selector(donePickingDate:) forControlEvents:UIControlEventValueChanged];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, datePicker.frame.size.width, 44.0)];
    toolbar.tintColor = [UIColor blackColor];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(removeDatePicker)];
    toolbar.items = [NSArray arrayWithObject:done];
        self.datePickerView.frame = CGRectMake(0.0, self.view.frame.size.height - datePicker.frame.size.height - toolbar.frame.size.height,
                                               self.view.frame.size.width,
                                               datePicker.frame.size.height + toolbar.frame.size.height);
        [_datePickerView addSubview:datePicker];
        [_datePickerView addSubview:toolbar];
        [self.view addSubview:_datePickerView];

    }
    return _datePickerView;
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.comments resignFirstResponder];
}

@end
