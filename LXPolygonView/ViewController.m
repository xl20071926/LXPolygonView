//
//  ViewController.m
//  LXPolygonView
//
//  Created by Leexin on 17/2/5.
//  Copyright © 2017年 Garden.Lee. All rights reserved.
//

#import "ViewController.h"
#import "LXPolygonView.h"

@interface ViewController () <UITextFieldDelegate>

@property (nonatomic, strong) LXPolygonView *polygonView;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)commonInit {
    
    self.polygonView = [[LXPolygonView alloc] initWithFrame:CGRectMake(100.f, 100.f, 200.f, 200.f) radius:80.f sideNumber:20];
    self.polygonView.valueArray = @[@(0.8), @(0.6), @(0.9), @(0.3), @(0.5), @(0.4), @(0.9), @(0.7)];
    self.polygonView.titleArray = @[@"力量", @"智力", @"敏捷", @"体质", @"耐力", @"忠诚", @"血量", @"速度"];
    [self.view addSubview:self.polygonView];
    
    self.textField.frame = CGRectMake((CGRectGetMaxX(self.view.frame) - 100.f) / 2, CGRectGetMaxY(self.polygonView.frame) + 50.f, 100.f, 30.f);
    [self.view addSubview:self.textField];
    
    self.resetButton.frame = CGRectMake((CGRectGetMaxX(self.view.frame) - 100.f) / 2, CGRectGetMaxY(self.textField.frame) + 20.f, 100.f, 30.f);
    [self.view addSubview:self.resetButton];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Event Response

- (void)onResetButtonClick {
    
    NSInteger newCount = [self.textField.text integerValue];
    if (newCount < 3) return;
    self.polygonView.sideNumber = newCount;
    [self.polygonView reloadPolygonView];
}

#pragma mark - Getters

- (UIButton *)resetButton {
    
    if (!_resetButton) {
        
        _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resetButton setTitle:@"刷新" forState:UIControlStateNormal];
        [_resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_resetButton addTarget:self action:@selector(onResetButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _resetButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _resetButton.layer.borderWidth = 1.f;
        _resetButton.layer.masksToBounds = YES;
    }
    return _resetButton;
}

- (UITextField *)textField {
    
    if (!_textField) {
        
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        _textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textField.layer.borderWidth = 1.f;
        _textField.layer.masksToBounds = YES;
    }
    return _textField;
}


@end
