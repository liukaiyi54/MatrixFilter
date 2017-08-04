//
//  WebViewController.m
//  PartyContacts
//
//  Created by Michael on 12/07/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import "WebViewController.h"
//#import "NativeInjector.h"

@interface WebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation WebViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self loadWebView];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
}

#pragma mark - private
- (void)setupViews {
    [self.view addSubview:self.webView];
    [self.view addSubview:self.indicator];
    self.indicator.center = self.indicator.superview.center;
}

- (void)loadWebView {
    [self.indicator startAnimating];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        _webView.delegate = self;
    }
    return _webView;
}

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indicator;
}

@end
