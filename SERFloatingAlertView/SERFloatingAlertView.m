//
//  SERFloatingAlertView.m
//
//  Created by Stanley Rost on 30.05.13.
//  Copyright (c) 2013 Stanley Rost. All rights reserved.
//

#import "SERFloatingAlertView.h"
#import "SKBounceAnimation.h"
#import "UIView+EasingFunctions.h"
#import "easing.h"

static const CGFloat kPadding = 9.0;
static const CGFloat kContentPaddingVertical   = 12.0;
static const CGFloat kContentPaddingHorizontal = 16.0;
static const CGFloat kInnerPaddingHorizontal   = 12.0;

@interface SERFloatingAlertView ()
{
  CGPoint _panOrigin;
}
@end

@implementation SERFloatingAlertView

- (id)initWithText:(NSString *)text
{
  CGRect frame = CGRectMake(0.0, 0.0, 320.0, 30.0);
  
  self = [super initWithFrame:frame];
  if (self)
  {
    _text = text;

    _label                 = [[UILabel alloc] initWithFrame:frame];
    _label.backgroundColor = [UIColor clearColor];
    _label.numberOfLines   = 0;
    _label.shadowColor     = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    _imageView           = [[UIImageView alloc] init];
    _backgroundImageView = [[UIImageView alloc] init];

    _presentationMode = SERFloatingAlertViewPresentationModeFromBottom;
  }
  return self;
}

// NOTE this does not check if alert view fits in view at all or image leaves enough space for text or such
- (void)presentInView:(UIView *)view
{
  [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  
  CGFloat width = view.bounds.size.width - 2.0 * kPadding;
  CGFloat contentWidth = width - 2.0 * kContentPaddingHorizontal;
  CGFloat textWidth = contentWidth;
  CGSize imageSize;

  if (self.imageView.image)
  {
    imageSize = self.imageView.image.size;
    textWidth -= imageSize.width + kInnerPaddingHorizontal;
  }

  self.label.text = self.text;
  self.label.frame = CGRectMake(
    contentWidth - textWidth + kContentPaddingHorizontal,
    kContentPaddingVertical,
    textWidth,
    0.0);
  
  [self.label sizeToFit]; // sizeThatFits does not work with numberOfLines = 0?
  
  CGFloat contentHeight = fmaxf(self.label.frame.size.height, imageSize.height);
  
  self.frame = CGRectMake(
    kPadding,
    kPadding,
    contentWidth + 2.0 * kContentPaddingHorizontal,
    contentHeight + 2.0 * kContentPaddingVertical);
  
  self.imageView.frame = CGRectMake(
    kContentPaddingHorizontal,
    kContentPaddingVertical + (contentHeight - imageSize.height) / 2.0,
    imageSize.width,
    imageSize.height
  );
  
  self.backgroundImageView.frame = self.bounds;
  
  [self addSubview:self.backgroundImageView];
  [self addSubview:self.imageView];
  [self addSubview:self.label];
  
  [view addSubview:self];
  
  CGPoint origin = self.frame.origin;
  
  CATransform3D initialTransform3D = CATransform3DIdentity;
  CATransform3D finalTransform3D   = CATransform3DIdentity;
  CGAffineTransform initialTransform = CGAffineTransformIdentity;
  CGAffineTransform finalTransform   = CGAffineTransformIdentity;

  if (self.presentationMode == SERFloatingAlertViewPresentationModeFromBottom)
  {
    origin = CGPointMake(
      CGRectGetMinX(self.frame) + self.offset.width,
      CGRectGetMaxY(view.bounds) - CGRectGetHeight(self.frame) - kPadding + self.offset.height);
      
    initialTransform = CGAffineTransformMakeTranslation(0.0, view.frame.size.height + 2.0 * kPadding);
    initialTransform3D = CATransform3DMakeTranslation(0.0, view.frame.size.height + 2.0 * kPadding, 0.0);
  }
  
  CGRect newFrame = self.frame;
  newFrame.origin = origin;
  self.frame = newFrame;

  BOOL animation1 = NO;
  if (animation1)
  {
    self.transform = initialTransform;
    [UIView animateWithDuration:0.35 animations:^{
      [self setEasingFunction:CircularEaseOut forKeyPath:@"transform"];
      self.transform = finalTransform;
    } completion:^(BOOL finished) {
      [self removeEasingFunctionForKeyPath:@"transform"];
    }];
  }
  else
  {
    NSString *keyPath = @"transform";
    self.layer.transform = initialTransform3D;
    id finalValue = [NSValue valueWithCATransform3D:finalTransform3D];
  
    SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:keyPath];
    bounceAnimation.fromValue           = [NSValue valueWithCATransform3D:initialTransform3D];
    bounceAnimation.toValue             = finalValue;
    bounceAnimation.duration            = 0.7f;
    bounceAnimation.numberOfBounces     = 4;
    bounceAnimation.shouldOvershoot     = NO;
    bounceAnimation.removedOnCompletion = YES;
  
    [self.layer addAnimation:bounceAnimation forKey:@"bounce"];
    [self.layer setValue:finalValue forKeyPath:keyPath];
  }
  
  UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
  [self addGestureRecognizer:tapRecognizer];

  UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
  [self addGestureRecognizer:panRecognizer];
}

- (void)dismiss
{
  [self dismissAndFireCallback:NO]; // explicitely dismissing will not trigger callback
}

- (void)dismissAndFireCallback:(BOOL)shouldFireCallback
{
  CGPoint finalCenter = self.center;
  finalCenter.y += CGRectGetMaxY(self.superview.frame) + self.frame.size.height;
  [UIView animateWithDuration:0.4 animations:^{
    [self setEasingFunction:CircularEaseIn forKeyPath:@"center"]; // looks similar to falling down, gravitational accelaration
    self.center = finalCenter;
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    [self removeEasingFunctionForKeyPath:@"center"];
    
    if (shouldFireCallback && self.afterDismissalBlock != NULL)
      self.afterDismissalBlock();
  }];
}

- (void)tapped:(id)sender
{
  [self dismissAndFireCallback:YES];
}

- (void)panned:(UIPanGestureRecognizer *)sender
{
  if (sender.state == UIGestureRecognizerStateBegan)
  {
    _panOrigin = self.center;
  }
  else if (sender.state == UIGestureRecognizerStateChanged)
  {
    CGPoint tp = [sender translationInView:sender.view];
    CGPoint center = _panOrigin;

    if (tp.y >= 0)
    {
      center.y += tp.y;
    }
    else
    {
      // simple kind of rubber band effect
      CGFloat max_ty = self.frame.size.height / 1.3;
      CGFloat weight_factor = max_ty / (max_ty - tp.y);
      center.y += tp.y * weight_factor;
    }
    
    self.center = center;
  }
  else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
  {
    [self dismissAndFireCallback:YES];
  }
}

@end
