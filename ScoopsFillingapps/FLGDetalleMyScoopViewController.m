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
                                                            photo:nil
                                                             text:item[@"text"]
                                                           author:item[@"author"]
                                                            coord:CLLocationCoordinate2DMake([item[@"latitude"] doubleValue], [item[@"longitude"] doubleValue])
                                                           status:item[@"status"]
                                                            score:item[@"score"]
                                                          scoopId:item[@"id"]];
                       
                       self.scoop = scoop;
                   }
                   [self syncViewToModel];
               }else{
                   NSLog(@"error --> %@", error);
               }
           }];
}

- (void)sendStatusToAzureWithAPI{
    
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
               }else{
                   NSLog(@"error --> %@", error);
               }
           }];
}

#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)publish:(id)sender{
    [self sendStatusToAzureWithAPI];
}

#pragma mark - Utils

- (void) configScreenAppearance{
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textView.layer.cornerRadius = 10;
    self.imageView.layer.cornerRadius = 10;
    self.imageView.layer.masksToBounds = YES;
    
    self.publicarButton.hidden = YES;
}

- (void) syncViewToModel{
    
    self.titleView.text = self.scoop.title;
    self.authorView.text = self.scoop.author;
    self.textView.text = self.scoop.text;
    self.statusView.text = self.scoop.status;
    
    self.publicarButton.hidden = ![self.scoop.status isEqualToString:@"notPublished"];
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
