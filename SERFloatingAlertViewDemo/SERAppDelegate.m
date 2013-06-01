//
//  SERAppDelegate.m
//  SERFloatingAlertViewDemo
//
//  Created by Stanley Rost on 01.06.13.
//  Copyright (c) 2013 Stanley Rost. All rights reserved.
//

#import "SERAppDelegate.h"
#import "SERViewController.h"

@implementation SERAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  
  self.window.rootViewController = [SERViewController new];
  
  [self.window makeKeyAndVisible];
  return YES;
}

@end
