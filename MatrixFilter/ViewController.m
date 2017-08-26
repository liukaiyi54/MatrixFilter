//
//  ViewController.m
//  MatrixFilter
//
//  Created by Michael on 31/07/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import "MatrixDataViewController.h"

#import "FilterManager.h"
#import "FileManager.h"

#import <ChameleonFramework/Chameleon.h>

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, MatrixDataViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *saveMatrixButton;
@property (nonatomic, strong) UIImage *cachedImage;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL isFirstTime;
@property (nonatomic, assign) BOOL fromSavingTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Color Matrix Filter";
    self.isFirstTime = YES;
    
    for (UITextField *textField in self.textFields) {
        textField.delegate = self;
    }
    
    self.imageView.image = [UIImage imageNamed:@"haizhu.jpeg"];
    self.cachedImage = self.imageView.image;
    
    [self addNotification];
    [self configureNavigationBar];
    [self configureButtons];
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
    WebViewController *webVC = [[WebViewController alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Color Matrix Filter" ofType:@"html"];
    webVC.path = path;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)saveData:(UIButton *)sender {
    NSMutableArray *matrix = [[NSMutableArray alloc] initWithCapacity:20];
    
    self.fromSavingTextField = YES;
    
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
    
    if (!self.fromSavingTextField) {
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
        self.fromSavingTextField = YES;
    }
}

- (void)addNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(showImage) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)configureNavigationBar {
    [self.navigationController setHidesNavigationBarHairline:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor flatMintColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)configureButtons {
    self.selectButton.layer.cornerRadius = 6.0f;
    self.saveButton.layer.cornerRadius = 6.0f;
    self.saveMatrixButton.layer.cornerRadius = 6.0f;
}

@end
