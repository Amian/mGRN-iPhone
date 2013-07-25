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
#import <MobileCoreServices/UTCoreTypes.h>
#import "CoreDataManager.h"
#import "PhotoPreviewVC.h"
#import "GRNPurchaseOrderViewController.h"
#import "SDN+Management.h"
#import "PurchaseOrderItem+Management.h"
#import "GRNItem+Management.h"
#import "GRNOrderItemViewController.h"
#import "LoadingView.h"
@interface GRNCompleteGrnViewController () <UIImagePickerControllerDelegate, UIAlertViewDelegate, UITextViewDelegate>
@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;
@property (nonatomic, strong) UIImage *image3;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIView *datePickerView;
@property (nonatomic, strong) UIView *loadingView;
@end

@implementation GRNCompleteGrnViewController

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self removeDatePicker];
}

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
    [self displayGRN];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)displayGRN
{
    [self.view addSubview:self.loadingView];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd/MM/yyyy";
        NSString *date;
        date = [formatter stringFromDate:self.grn.deliveryDate? self.grn.deliveryDate : [NSDate date]];
        [self.dateButton setTitle:date forState:UIControlStateNormal];
        self.comments.text = self.grn.notes;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.image1 = [UIImage imageWithData:[defaults objectForKey:KeyImage1]];
        self.image2 = [UIImage imageWithData:[defaults objectForKey:KeyImage2]];
        self.image3 = [UIImage imageWithData:[defaults objectForKey:KeyImage3]];
        if (self.image1 || self.image2 || self.image3)
        {
            [self refreshImageView];
        }
        [self.loadingView removeFromSuperview];
    }];
}


- (IBAction)takePhoto:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = (id)self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects: (NSString *) kUTTypeImage,nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
    }
}


#pragma mark - ImagePicker Delegate Method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self dismissModalViewControllerAnimated:YES];
    int index = 0;
    if (!self.image1)
    {
        index = 1;
        self.image1 = image;
    }
    else if (!self.image2)
    {
        index = 2;
        self.image2 = image;
    }
    else if (!self.image3)
    {
        index = 3;
        self.image3 = image;
    }
    else
    {
        return;
    }
        
    [self refreshImageView];
    [self.view addSubview:self.loadingView];
    [self performSelector:@selector(saveImageNumber:) withObject:[NSNumber numberWithInt:index] afterDelay:0.1];
        
}

-(void)saveImageNumber:(NSNumber*)index
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch ([index intValue])
    {
        case 1:
        {
            self.grn.photo1URI = [self base64forData:UIImageJPEGRepresentation(self.image1, 0.5)];
            [defaults setValue:UIImagePNGRepresentation(self.image1) forKey:KeyImage1];
            break;
        }
        case 2:
        {
            self.grn.photo2URI = [self base64forData:UIImageJPEGRepresentation(self.image2, 0.5)];
            [defaults setValue:UIImagePNGRepresentation(self.image2) forKey:KeyImage2];
            break;
        }
        case 3:
        {
            self.grn.photo3URI = [self base64forData:UIImageJPEGRepresentation(self.image3, 0.5)];
            [defaults setValue:UIImagePNGRepresentation(self.image3) forKey:KeyImage3];
            break;
        }
        default:
            break;
    }
    [defaults synchronize];
    [self.loadingView removeFromSuperview];
    
//    NSString *s = [[NSString alloc] initWithData:[self base64DataforData:UIImageJPEGRepresentation(self.image1, 0.5)] encoding:NSASCIIStringEncoding];
//    NSLog(@"%@",[[NSString alloc] initWithData:[self base64DataforData:UIImageJPEGRepresentation(self.image1, 0.5)] encoding:NSASCIIStringEncoding]);
//    NSLog(@"%@",[self base64forData:UIImageJPEGRepresentation(self.image1, 0.5)]);
//    NSLog(@"%@",self.grn.photo1URI);
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


- (NSData*)base64DataforData:(NSData*)theData {
    
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
    
    return data;
}

- (IBAction)showDatePicker:(UIButton*)button
{
    [self.comments resignFirstResponder];
    self.datePickerView.hidden = NO;
    self.dateButton.superview.layer.borderColor = [UIColor orangeColor].CGColor;
}

- (IBAction)submit:(id)sender
{
    //Check signature
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:KeySignature])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The signature can't be blank."
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self.view addSubview:self.loadingView];
    [self performSelector:@selector(submitGRN) withObject:nil afterDelay:0.1];
    
}

-(void)submitGRN
{
    //If grn date wasnt set, set it to current date
    if (!self.grn.deliveryDate) self.grn.deliveryDate = [NSDate date];
    
    //Save Signature
    UIImage *signature = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:KeySignature]];
    self.grn.signatureURI = [self base64forData:UIImageJPEGRepresentation(signature ,1.f)];
    
    //Save remaining data
    self.grn.notes = self.comments.text;
    self.grn.submitted = [NSNumber numberWithBool:YES];
    
    //Add SDN to core data
    [SDN InsertSDN:self.grn.supplierReference InMOC:[CoreDataManager moc]];
    
    //Adjust purchase orders
    [self updatePurchaseOrder];
    
    //Save context
    NSError *error;
    [[CoreDataManager moc] save:&error];
    NSLog(@"Error = %@",error);
    
    //Add to submission queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void)
                   {
                       [[CoreDataManager sharedInstance] submitAnyGrnsAwaitingSubmittion];
                   });
    
    [[CoreDataManager sharedInstance] setCreatingGRN:NO];
    
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[GRNPurchaseOrderViewController class]])
        {
            [(GRNPurchaseOrderViewController*)vc setReturnedAfterSubmission:YES];
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
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
        if (self.grn.deliveryDate)
            datePicker.date = self.grn.deliveryDate;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"backToGrn1"])
    {
        self.grn.notes = self.comments.text;
        [[CoreDataManager moc] save:nil];
    }
    else if ([segue.identifier isEqualToString:@"imagePreview"])
    {
        PhotoPreviewVC *vc = segue.destinationViewController;
        vc.image = self.selectedImage;
    }
}

-(void)previewImage:(UIButton*)sender
{
    self.selectedImage = sender.tag == 1? self.image1 : sender.tag == 2? self.image2 : self.image3;
    [self performSegueWithIdentifier:@"imagePreview"
                              sender:self];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        switch (alertView.tag)
        {
            case 1:
                self.image1 = nil;
                [defaults setObject:nil forKey:KeyImage1];
                break;
            case 2:
                self.image2 = nil;
                [defaults setObject:nil forKey:KeyImage2];
                break;
            case 3:
                self.image3 = nil;
                [defaults setObject:nil forKey:KeyImage3];
                break;
            default:
                break;
        }
        [defaults synchronize];
        [self refreshImageView];
    }
}

-(void)updatePurchaseOrder
{
    PurchaseOrder *po = self.grn.purchaseOrder;
    int poItemsRemoved = 0;
    for (GRNItem *grnItem in self.grn.lineItems)
    {
        PurchaseOrderItem *poItem = grnItem.purchaseOrderItem;
        poItem.quantityBalance = [NSNumber numberWithInt:[[poItem quantityBalance] intValue] - ([grnItem.quantityDelivered intValue] - [grnItem.quantityRejected intValue])];
        if ([poItem.quantityBalance intValue] <= 0)
        {
            @try
            {
                [[CoreDataManager moc] deleteObject:poItem];
            }
            @catch (NSException *e)
            {
                //TOOD
            }
            poItemsRemoved++;
        }
    }
    if ([po.lineItems count] == poItemsRemoved)
    {
        @try
        {
            [[CoreDataManager moc] deleteObject:po];
        }
        @catch (NSException *e)
        {
            //TOOD
        }
    }
}

-(UIView*)loadingView
{
    if(!_loadingView)
    {
        _loadingView = [[LoadingView alloc] initWithFrame:self.view.bounds];
    }
    return _loadingView;
}
@end
