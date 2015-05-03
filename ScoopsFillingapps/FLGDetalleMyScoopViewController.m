//
//  FLGDetalleMyScoopViewController.m
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 1/5/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

#import "FLGDetalleMyScoopViewController.h"
#import "Scoop.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "SharedKeys.h"

@interface FLGDetalleMyScoopViewController ()

@property(strong, nonatomic)  MSClient *client;
@property (nonatomic) CGRect oldRect;

@end

@implementation FLGDetalleMyScoopViewController

- (id) initWithModel: (Scoop *) scoop{
    if (self = [super initWithNibName:nil
                               bundle:nil]) {
        _scoop = scoop;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupKeyboardNotifications];
    [self configScreenAppearance];
    
    [self warmUpAzure];
    [self populateModelFromAzureWithAPI];
}

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.screenName = @"myScoopsDetail";
    
    [self hideLoadingView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Azure

- (void) warmUpAzure{
    self.client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                             applicationKey:AZUREMOBILESERVICE_APPKEY];
}

- (void)populateModelFromAzureWithAPI{
    
    [self showLoadingView];
    [self.activityView startAnimating];
    
    NSDictionary *parameters = @{@"idNoticia" : _scoop.scoopId};
    
    [self.client invokeAPI:@"readonefullnew"
                 body:nil
           HTTPMethod:@"GET"
           parameters:parameters
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
               if (!error) {
                   NSLog(@"resultado --> %@", result);
                   for (id item in result) {
                       NSLog(@"item -> %@", item);
                       Scoop *scoop = [[Scoop alloc]initWithTitle:item[@"title"]
                                                        photoData:nil
                                                             text:item[@"text"]
                                                           author:item[@"author"]
                                                        authorID:item[@"authorID"]
                                                            coord:CLLocationCoordinate2DMake([item[@"latitude"] doubleValue], [item[@"longitude"] doubleValue])
                                                           status:item[@"status"]
                                                            score:[item[@"score"] floatValue]
                                                          scoopId:item[@"id"]
                                                        photoName:item[@"image"]];
                       
                       self.scoop = scoop;
                       NSString *blobName = scoop.photoName;
                       NSString *containerName = item[@"authorID"];
                       [self readBlobURLForBlobName:blobName inContainer:containerName];
                   }
                   [self syncViewToModel];
               }else{
                   NSLog(@"error --> %@", error);
                   [self.activityView stopAnimating];
               }
               [self hideLoadingView];
           }];
}

- (void)sendStatusToAzureWithAPI{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self showLoadingView];
    
    NSString *newStatus = @"pending";
    NSDictionary *parameters = @{@"idNoticia" : _scoop.scoopId, @"status" : newStatus};
    
    [self.client invokeAPI:@"updatestatus"
                 body:nil
           HTTPMethod:@"GET"
           parameters:parameters
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
               if (!error) {
                   NSLog(@"resultado --> %@", result);
                   self.scoop.status = newStatus;
                   [self syncViewToModel];
                   [self.delegate detalleMyScoopviewController:self
                                           didPublishNewWithId:self.scoop.scoopId];
                   
                   [[[UIAlertView alloc] initWithTitle:@"Genial!"
                                               message:@"Tu noticia ha sido publicada. En un par de horas estará disponible para los lectores."
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles: nil] show];
               }else{
                   NSLog(@"error --> %@", error);
                   [[[UIAlertView alloc] initWithTitle:@"Error!"
                                               message:@"Tu noticia ha podido ser publicada. Por favor, inténtalo más tarde."
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles: nil] show];
               }
               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
               [self hideLoadingView];
           }];
}

- (void) readBlobURLForBlobName: (NSString *) blobName inContainer: (NSString *)containerName {
    NSDictionary *parameters = @{@"containerName" : containerName, @"blobName" : blobName};
    
    [self.client invokeAPI:@"getbloburlfromauthorscontainer"
                      body:nil
                HTTPMethod:@"GET"
                parameters:parameters
                   headers:nil
                completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                    if (!error) {
                        NSLog(@"resultado --> %@", result);
                        [self handleSaSURLToDownload:[NSURL URLWithString:result[@"sasUrl"]] completionHandleSaS:^(UIImage* image, NSError *error) {
                            if (!error) {
                                self.imageView.image = image;
                            }else{
                                self.imageView.image = [UIImage imageNamed:@"no_image"];
                            }
                            [self.activityView stopAnimating];
                        }];
                    }else{
                        NSLog(@"error --> %@", error);
                    }
                }];
}

- (void)handleSaSURLToDownload:(NSURL *)theUrl completionHandleSaS:(void (^)(id result, NSError *error))completion{
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:theUrl];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDownloadTask * downloadTask = [[NSURLSession sharedSession]downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            
            NSLog(@"resultado --> %@", response);
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
            completion(image, error);
        }
    }];
    [downloadTask resume];
}

#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)publish:(id)sender{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *dictBuilder = [GAIDictionaryBuilder createEventWithCategory:@"writter"
                                                                               action:@"publish"
                                                                                label:nil
                                                                                value:nil];
    [tracker send: [dictBuilder build]];
    
    [self sendStatusToAzureWithAPI];
}

#pragma mark - Utils

- (void) configScreenAppearance{
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textView.layer.cornerRadius = 10;
    self.imageView.layer.cornerRadius = 10;
    self.imageView.layer.masksToBounds = YES;
    self.loadingView.layer.cornerRadius = 10;
    
    self.publicarButton.hidden = YES;
}

- (void) syncViewToModel{
    
    self.titleView.text = self.scoop.title;
    self.authorView.text = self.scoop.author;
    self.textView.text = self.scoop.text;
    self.statusView.text = self.scoop.status;
    self.scoreView.text = [NSString stringWithFormat:@"%.2f", self.scoop.score];
    
    self.publicarButton.hidden = ![self.scoop.status isEqualToString:@"notPublished"];
}

- (void) hideLoadingView{
    self.loadingVeloView.hidden = YES;
    [self.loadingActivityView stopAnimating];
}

- (void) showLoadingView{
    [self.loadingActivityView startAnimating];
    self.loadingVeloView.hidden = NO;
}

#pragma mark - keyboard

- (void)setupKeyboardNotifications{
    
    // Alta en notificaciones
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(notifyKeyboardWillAppear:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(notifyKeyboardWillDisappear:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
}

//UIKeyboardWillShowNotification
-(void)notifyKeyboardWillAppear: (NSNotification *) notification{
    
    // Obtener el frame del teclado
    NSDictionary *info = notification.userInfo;
    NSValue *keyFrameValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyFrame = [keyFrameValue CGRectValue];
    
    
    // La duración de la animación del teclado
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Nuevo CGRect
    self.oldRect = self.textView.frame;
    CGRect newRect = CGRectMake(self.oldRect.origin.x,
                                self.oldRect.origin.y,
                                self.oldRect.size.width,
                                self.oldRect.size.height - keyFrame.size.height);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:0
                     animations:^{
                         self.textView.frame = newRect;
                         self.imageView.hidden = YES;
                     } completion:^(BOOL finished) {
                         //
                     }];
    
}

// UIKeyboardWillHideNotification
-(void)notifyKeyboardWillDisappear: (NSNotification *) notification{
    
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:0
                     animations:^{
                         self.textView.frame = self.oldRect;
                         self.imageView.hidden = NO;
                     } completion:^(BOOL finished) {
                         //
                     }];
}

@end
