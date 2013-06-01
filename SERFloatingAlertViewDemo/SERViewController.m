//
//  SERViewController.m
//  SERFloatingAlertViewDemo
//
//  Created by Stanley Rost on 01.06.13.
//  Copyright (c) 2013 Stanley Rost. All rights reserved.
//

#import "SERViewController.h"
#import "SERFloatingAlertView.h"

@interface SERViewController ()

@property (nonatomic, strong) SERFloatingAlertView *floatingAlertView;
@property (nonatomic, strong) UIButton *button;

@end

@implementation SERViewController

#pragma mark View lifecycle management

- (void)loadView
{
  self.view = [UIView new];
  
  self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.button setTitle:@"Show or hide message" forState:UIControlStateNormal];
  [self.button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.button sizeToFit];
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 75)];
  label.numberOfLines = 0;
  label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
  label.text = @"Showing message, tap or drag to dismiss. Press the button a couple of times to see one of three messages randomly with or without an image.";

  [self.view addSubview:self.button];
  [self.view addSubview:label];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.button.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  [self showAlert];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  [self.floatingAlertView removeFromSuperview];
  self.floatingAlertView = nil;
}

#pragma mark Actions

- (void)buttonPressed:(id)sender
{
  if (self.floatingAlertView)
  {
    [self hideAlert];
  }
  else
  {
    [self showAlert];
  }
}

#pragma mark Alert

- (void)showAlert
{
  NSString *message = nil;
  
  switch (arc4random() % 3)
  {
    case 0:  message = @"Hola!"; break;
    case 1:  message = @"A fatal error occurred in foo. Please contact support."; break;
    default: message = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."; break;
  }
  
  self.floatingAlertView = [[SERFloatingAlertView alloc] initWithText:message];

  // if (arc4random() % 2)
    self.floatingAlertView.imageView.image = [UIImage imageNamed:@"notice.png"];

  self.floatingAlertView.backgroundImageView.image =
      [[UIImage imageNamed:@"background.png"]
        resizableImageWithCapInsets:UIEdgeInsetsMake(5, 4, 6, 4)];

  self.floatingAlertView.label.font      = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
  self.floatingAlertView.label.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
  
  [self.floatingAlertView presentInView:self.view];

  __weak __typeof(self) weakSelf = self;
  self.floatingAlertView.afterDismissalBlock = ^{
    weakSelf.floatingAlertView = nil;
  };
}

- (void)hideAlert
{
  [self.floatingAlertView dismiss];
  self.floatingAlertView = nil;
}

@end
