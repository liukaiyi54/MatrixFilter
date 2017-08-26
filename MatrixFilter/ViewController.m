//
//  ViewController.m
//  MatrixFilter
//
//  Created by Michael on 31/07/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import "SVModalWebViewController.h"
#import "MatrixDataViewController.h"

#import "FilterManager.h"
#import "FileManager.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, MatrixDataViewControllerDelegate>

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *cachedImage;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL isFirstTime;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirstTime = YES;
    
    for (UITextField *textField in self.textFields) {
        textField.delegate = self;
    }
    
    self.imageView.image = [UIImage imageNamed:@"haizhu.jpeg"];
    self.cachedImage = self.imageView.image;
    
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
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (IBAction)didTapMatrixData:(id)sender {
    MatrixDataViewController *vc = [[MatrixDataViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapDetailButton:(id)sender {
    SVModalWebViewController *webView = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:@"https://liukaiyi54.github.io/osx/2017/04/12/mosaic.html"]];
    
    [self presentViewController:webView animated:YES completion:nil];
}

- (IBAction)saveData:(UIButton *)sender {
    NSMutableArray *matrix = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (NSInteger i = 0; i < self.textFields.count; i++) {
        UITextField *textField = self.textFields[i];
        [matrix addObject:[NSNumber numberWithFloat:textField.text.floatValue]];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"保存滤镜参数" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入名称";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        if (textField.text) {
            FileManager *manager = [FileManager sharedInstance];
            [manager.file setObject:matrix forKey:textField.text];
            [manager saveFile];
        }
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:saveAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    self.cachedImage = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0.0;
        self.view.frame = frame;
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGFloat extraPaddingForPlus = 0;
    if (CGRectGetHeight(self.view.frame) > 700) {
        extraPaddingForPlus = 10.0f;
    }

    CGFloat offset = 42 - self.keyboardHeight;
    if (offset <= 0) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = offset;
            self.view.frame = frame;
        }];
    }
    return YES;
}

- (void)MatrixDataViewController:(MatrixDataViewController *)vc didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *matrix = [[FileManager sharedInstance].file allValues][indexPath.row];
    
    for (NSInteger i = 0; i < self.textFields.count; i++) {
        UITextField *textField = self.textFields[i];
        float f = [matrix[i] floatValue];
        textField.text = [NSString stringWithFormat:@"%.1f", f];
    }
    [self showImage];
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
    
    if (self.isFirstTime || self.keyboardHeight > 216) {
        CGFloat offset = 42 - self.keyboardHeight;
        if (offset <= 0) {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = self.view.frame;
                frame.origin.y = offset;
                self.view.frame = frame;
            }];
        }
        self.isFirstTime = NO;
    }
}

@end
