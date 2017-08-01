//
//  ViewController.m
//  MatrixFilter
//
//  Created by Michael on 31/07/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import "ViewController.h"

#import "FilterManager.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *cachedImage;
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UITextField *textField in self.textFields) {
        textField.delegate = self;
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(showImage) name:UITextFieldTextDidChangeNotification object:nil];
}

- (IBAction)selectPhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)savePhoto:(UIButton *)sender {
    
}

#pragma mark - delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    self.cachedImage = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITextField *field in self.textFields) {
        [field resignFirstResponder];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGFloat extraPaddingForPlus = 0;
    if (CGRectGetHeight(self.view.frame) > 700) {
        extraPaddingForPlus = 10.0f;
    }
    CGFloat offset = self.view.frame.size.height - (textField.frame.origin.y + textField.frame.size.height + self.keyboardHeight + extraPaddingForPlus);
    if (offset <= 0) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = offset;
            self.view.frame = frame;
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0.0;
        self.view.frame = frame;
    }];
    return YES;
}

#pragma mark - private
- (void)showImage {
    float matrix[20];
    
    for (NSInteger i = 0; i < self.textFields.count; i++) {
        UITextField *textField = self.textFields[i];
        matrix[i] = textField.text.floatValue;
    }
    FilterManager *manager = [[FilterManager alloc] init];
    self.imageView.image = [manager createImageWithImage:self.cachedImage colorMatrix:matrix];
}

-(void)keyboardOnScreen:(NSNotification *)notification {
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    self.keyboardHeight = CGRectGetHeight(keyboardFrame);
    
    NSLog(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
}

@end
