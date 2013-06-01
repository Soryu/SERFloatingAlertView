//
//  SERFloatingAlertView.h
//
//  Created by Stanley Rost on 30.05.13.
//  Copyright (c) 2013 Stanley Rost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SERFloatingAlertViewPresentationModeFromBottom
} SERFloatingAlertViewPresentationMode;


@interface SERFloatingAlertView : UIView

- (id)initWithText:(NSString *)text;
- (void)presentInView:(UIView *)view;
- (void)dismiss;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, assign) SERFloatingAlertViewPresentationMode presentationMode;
@property (nonatomic, assign) CGSize offset;

@property (nonatomic, copy) void(^afterDismissalBlock)(void);

@end
