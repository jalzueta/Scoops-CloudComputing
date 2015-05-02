//
//  AppDelegate.m
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 29/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

#import "AppDelegate.h"
#import "GAI.h"
#import "GAITracker.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "SharedKeys.h"
#import "FLGLoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self registerNotificationRemotes];
    
    // -------------------- Google Analytics ---------------------------------
    // Configurar comportamiento
    [GAI sharedInstance].trackUncaughtExceptions = NO; // No captura las excepciones
    [GAI sharedInstance].dispatchInterval = 30;
    
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose]; // Sacara por consola los tracks de GA
    
    // Iniciamos la captura
    [[GAI sharedInstance] trackerWithTrackingId:UA_ANALYTICS];
    // -----------------------------------------------------------------------
    
    
    FLGLoginViewController *loginVC = [[FLGLoginViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = navVC;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - push notification para Azure

- (void)registerNotificationRemotes{
    
    UIApplication *application = [UIApplication sharedApplication];
    
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound |UIUserNotificationTypeAlert )
                                                                             categories:nil];
    
    [application registerUserNotificationSettings:settings];
    
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    MSClient *client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT] applicationKey:AZUREMOBILESERVICE_APPKEY];
    
    [client.push registerNativeWithDeviceToken:deviceToken tags:@[@"Mi etiqueta"] completion:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
        }
    }];
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Error -> %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    NSLog(@"%@", userInfo);
    NSString *msg = userInfo[@"aps"][@"alert"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Titulo de la Notificación"
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
}

@end
