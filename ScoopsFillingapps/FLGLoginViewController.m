//
//  FLGLoginViewController.m
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 29/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

#import "FLGLoginViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "Scoop.h"
#import "SharedKeys.h"
#import "FLGNewScoopViewController.h"
#import "FLGAllScoopTableViewController.h"

//@import QuartzCore;
@import CoreLocation;

@interface FLGLoginViewController ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIControl *loadingVeloView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityView;

@property (strong, nonatomic) MSClient *client;
@property (strong, nonatomic) NSString *userFBId;
@property (strong, nonatomic) NSString *tokenFB;

@property (nonatomic, strong) id userInfo;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation FLGLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Scoops by FillinGAPPs";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // llamamos a los metodos de Azure para crear y configurar la conexion
    [self warmupMSClient];
}

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.screenName = @"login";
    
    self.skipButton.layer.cornerRadius = 5;
    self.loginButton.layer.cornerRadius = 5;
    self.loadingView.layer.cornerRadius = 10;
    
    [self hideLoadingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Azure connect, setup, login etc...

- (void) warmupMSClient{
    self.client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                 applicationKey:AZUREMOBILESERVICE_APPKEY];
    
    NSLog(@"%@", self.client.debugDescription);
}

#pragma mark - Actions

- (IBAction)skipLogin:(id)sender {
    [self launchReaderMode];
}

- (IBAction)login:(id)sender {
    
    [self loginAppInViewController:self withCompletion:^(NSArray *results) {
        
        NSLog(@"Resultados ---> %@", results);
    }];
}

#pragma mark - Utils
- (void) hideLoadingView{
    self.loadingVeloView.hidden = YES;
    [self.loadingActivityView stopAnimating];
}

- (void) showLoadingView{
    [self.loadingActivityView startAnimating];
    self.loadingVeloView.hidden = NO;
}

#pragma mark - Login

- (void) loginAppInViewController:(UIViewController *)controller withCompletion:(completeBlock)bloque{
    
    [self loadUserAuthInfo];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self showLoadingView];
    
    if (self.client.currentUser){
        [self.client invokeAPI:@"getCurrentUserInfo"
                          body:nil
                    HTTPMethod:@"GET"
                    parameters:nil
                       headers:nil
                    completion:^(id userInfo, NSHTTPURLResponse *response, NSError *error) {
                        
                        //tenemos info extra del usuario
                        self.userInfo = userInfo;
                        NSLog(@"%@", userInfo);
                        //            self.profilePicture = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
                        [self launchWritterModeWithUser: userInfo];
                    }];
        
        return;
    }
    
    [self.client loginWithProvider:@"facebook"
                   controller:controller
                     animated:YES
                   completion:^(MSUser *user, NSError *error) {
                       
                       if (error) {
                           NSLog(@"Error en el login : %@", error);
                           bloque(nil);
                           [[[UIAlertView alloc] initWithTitle:@"Error!"
                                                       message:@"No se ha podido iniciar sesión. Por favor, inténtalo de nuevo."
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil] show];
                           [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                           [self hideLoadingView];
                       } else {
                           NSLog(@"user -> %@", user);
                           
                           [self saveAuthInfo];
                           [self.client invokeAPI:@"getCurrentUserInfo"
                                             body:nil
                                       HTTPMethod:@"GET"
                                       parameters:nil
                                          headers:nil
                                       completion:^(id userInfo, NSHTTPURLResponse *response, NSError *error) {
                                           
                                           //tenemos info extra del usuario
                                           self.userInfo = userInfo;
                                           NSLog(@"%@", userInfo);
//                               self.profilePicture = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
                                           [self launchWritterModeWithUser:userInfo];
                                       }];
                           
                           bloque(@[user]);
                       }
                   }];
}

- (BOOL) loadUserAuthInfo{
    
    self.userFBId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"];
    self.tokenFB = [[NSUserDefaults standardUserDefaults]objectForKey:@"tokenFB"];
    
    if (self.userFBId) {
        self.client.currentUser = [[MSUser alloc]initWithUserId:self.userFBId];
        self.client.currentUser.mobileServiceAuthenticationToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"tokenFB"];

        return YES;
    }
    return NO;
}

- (void) saveAuthInfo{
    [[NSUserDefaults standardUserDefaults]setObject:[self.client.currentUser.userId stringByReplacingOccurrencesOfString:@"Facebook:" withString:@""] forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults]setObject:self.client.currentUser.mobileServiceAuthenticationToken
                                             forKey:@"tokenFB"];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void) launchWritterModeWithUser: (id) userInfo{
    
    NSData *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    
    [self.client.push registerNativeWithDeviceToken:deviceToken tags:@[userID] completion:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
        }
    }];
    
    [self addAuthorToAzure];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self hideLoadingView];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"writterMode"];
    [self askForLocationPermissions];
}

- (void) openAppInWritterMode{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *dictBuilder = [GAIDictionaryBuilder createEventWithCategory:@"login"
                                                                               action:@"mode"
                                                                                label:@"writter" // Nombre del producto consultado
                                                                                value:nil];
    [tracker send: [dictBuilder build]];
    
    FLGNewScoopViewController *newScoopVC = [[FLGNewScoopViewController alloc] initWithUser: self.userInfo
                                                                                     client: self.client];
//    newScoopVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:newScoopVC
//                       animated:YES
//                     completion:nil];
    
    [self.navigationController pushViewController:newScoopVC
                                         animated:YES];

}

- (void) launchReaderMode{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"writterMode"];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *dictBuilder = [GAIDictionaryBuilder createEventWithCategory:@"login"
                                                                               action:@"mode"
                                                                                label:@"reader" // Nombre del producto consultado
                                                                                value:nil];
    [tracker send: [dictBuilder build]];
    
    FLGAllScoopTableViewController *allScoopsVC = [[FLGAllScoopTableViewController alloc] init];
//    navVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:navVC
//                       animated:YES
//                     completion:nil];
    [self.navigationController pushViewController:allScoopsVC
                                         animated:YES];
}

#pragma mark - Location

- (void) askForLocationPermissions{
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
        } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
        } else {
            NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
        }
    }else{
        [self openAppInWritterMode];
    }
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        
        [self openAppInWritterMode];
    }
}

#pragma mark - APIs personalizadas

- (void)addAuthorToAzure{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    MSTable *authors = [self.client tableWithName:@"authors"];
    
    NSString *userID = [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"];
    NSData *deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
    NSString *deviceTokenString = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
    if (!deviceTokenString) {
        deviceTokenString = [NSString stringWithUTF8String:[deviceToken bytes]];
    }
    
    NSDictionary * author= @{@"authorid" : userID,
                            @"notificationsid" : @"estoyEnEllo"};
    
    [authors insert:author
      completion:^(NSDictionary *item, NSError *error) {
          
          if (!error) {
              NSLog(@"OK");
              
          } else {
              
              NSLog(@"Error %@", error);
          }
      }];
}



@end
