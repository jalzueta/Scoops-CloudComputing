//
//  FLGNewScoopViewController.m
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 30/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

#import "FLGNewScoopViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "FLGConstants.h"
#import "SharedKeys.h"
#import "FLGAllScoopTableViewController.h"
#import "FLGMyScoopsTableViewController.h"

@import CoreLocation;

@interface FLGNewScoopViewController ()<CLLocationManagerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) id userInfo;
@property (nonatomic) CGRect oldRect;
@property (strong, nonatomic) MSClient *client;
@property (strong, nonatomic) NSString *authorID;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;

@property (strong, nonatomic) UIActionSheet *photoMenu;
@property (strong, nonatomic) NSData *photoData;

@property (strong, nonatomic) NSURLSessionDataTask *uploadTask;

@end

@implementation FLGNewScoopViewController

- (id) initWithUser: (id) userInfo
             client: (MSClient *) client{
    if (self = [super initWithNibName:nil
                               bundle:nil]) {
        _userInfo = userInfo;
        _client = client;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupKeyboardNotifications];
//    [self askForLocationPermissions];
}

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.screenName = @"NewScoop";
    
    [self configScreenAppearance];
    [self configAuthor];
    
    [self getUserLocation];
    
    [self hideLoadingView];
}

- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *dictBuilder = [GAIDictionaryBuilder createEventWithCategory:@"screen"
                                                                               action:@"enter"
                                                                                label:@"newScoop"
                                                                                value:0];
    [tracker send: [dictBuilder build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.oldRect = self.scoopTextView.frame;
    CGRect newRect = CGRectMake(self.oldRect.origin.x,
                                self.oldRect.origin.y,
                                self.oldRect.size.width,
                                self.oldRect.size.height - keyFrame.size.height + self.toolBarView.frame.size.height);
    
    self.photoView.hidden = YES;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:0
                     animations:^{
                         self.scoopTextView.frame = newRect;
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
                         self.scoopTextView.frame = self.oldRect;
                     } completion:^(BOOL finished) {
                         self.photoView.hidden = NO;
                     }];
}


#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)addScoop:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *dictBuilder = [GAIDictionaryBuilder createEventWithCategory:@"writter"
                                                                               action:@"addScoop"
                                                                                label:@""
                                                                                value:nil];
    [tracker send: [dictBuilder build]];
    
    [self addScoopToAzure];
}

- (IBAction)myScoops:(id)sender {
    FLGMyScoopsTableViewController *myScoopsVC = [[FLGMyScoopsTableViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:myScoopsVC];
    [self presentViewController:navVC
                       animated:YES
                     completion:nil];
}

- (IBAction)allScoops:(id)sender{
    FLGAllScoopTableViewController *allScoopsVC = [[FLGAllScoopTableViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:allScoopsVC];
    [self presentViewController:navVC
                       animated:YES
                     completion:nil];
}

- (IBAction)takePhoto:(id)sender {
    
    if (!self.photoMenu) {
        self.photoMenu = [[UIActionSheet alloc] initWithTitle:@"Select Photo Source:"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:
                          @"Camera",
                          @"Roll",
                          @"Album",
                          @"Delete",
                          nil];
    }
    [self.photoMenu showInView:[UIApplication sharedApplication].keyWindow];
}


#pragma mark - Utils

- (void) configScreenAppearance{
    self.scoopTextView.layer.borderWidth = 0.5;
    self.scoopTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.scoopTextView.layer.cornerRadius = 10;
    self.photoView.layer.cornerRadius = 10;
    self.photoView.layer.masksToBounds = YES;
    self.loadingView.layer.cornerRadius = 10;
}

- (void) configAuthor{
    NSURL *profilePictureURL = [NSURL URLWithString:self.userInfo[@"picture"][@"data"][@"url"]];
    [self setProfilePicture: profilePictureURL];
    self.scoopAuthorView.text = self.userInfo[@"name"];
    self.authorID = self.userInfo[@"id"];
}

-(void)setProfilePicture:(NSURL *)profilePicture{
    
    dispatch_queue_t queue = dispatch_queue_create("com.byjuanamn.serial", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        
        NSData *buff = [NSData dataWithContentsOfURL:profilePicture];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scoopAuthorImageView.image = [UIImage imageWithData:buff];
            self.scoopAuthorImageView.layer.cornerRadius = self.scoopAuthorImageView.frame.size.width / 2;
            self.scoopAuthorImageView.clipsToBounds = YES;
        });
    });
}

- (void) hideLoadingView{
    self.loadingVeloView.hidden = YES;
    [self.loadingActivityView stopAnimating];
}

- (void) showLoadingView{
    [self.loadingActivityView startAnimating];
    self.loadingVeloView.hidden = NO;
}

-(NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

- (void) syncroPhotoImage{
    if (self.photoData) {
        self.photoView.image = [UIImage imageWithData:self.photoData];
    }else{
        self.photoView.image = [UIImage imageNamed:@"no_image"];
    }
}

- (UIImage *) thumbnailFromImage: (UIImage *) originalImage{
    CGFloat scale = originalImage.size.height/originalImage.size.width;
    CGFloat destinationWidth = 160;
    CGFloat destinationHeight = destinationWidth * scale;
    CGSize destinationSize = CGSizeMake(destinationWidth, destinationHeight);
    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbnailImage;
}

#pragma mark - Azure

- (void)addScoopToAzure{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self showLoadingView];
    
    MSTable *news = [self.client tableWithName:@"news"];
    
    NSString *blobName = [self randomStringWithLength:20];
    NSString *blobNameWithExtension = [NSString stringWithFormat:@"%@.jpg", blobName];
    NSString *thumbBlobNameWithExtension = [NSString stringWithFormat:@"%@_thumb.jpg", blobName];
    
    NSDictionary * scoop= @{@"title" : self.scoopTitleView.text,
                            @"text" : self.scoopTextView.text,
                            @"author" : self.scoopAuthorView.text,
                            @"authorID" : self.authorID,
                            @"image" : blobNameWithExtension,
                            @"latitude" : @(self.location.coordinate.latitude),
                            @"longitude" : @(self.location.coordinate.longitude)};
    [news insert:scoop
      completion:^(NSDictionary *item, NSError *error) {
          
          if (!error) {
              NSLog(@"OK");
              
              if (self.photoData) { // Si se ha cargado una photo, se sube al server
                  NSString *containerName = self.client.currentUser.userId;
                  
                  // se lanza la carga de la imagen grande
                  [self readBlobURLForBlobName:blobNameWithExtension inContainer:containerName forImage:self.photoView.image];
                  
                  // se lanza la carga de la imagen thumb
                  [self readBlobURLForBlobName:thumbBlobNameWithExtension inContainer:containerName forImage:[self thumbnailFromImage:self.photoView.image]];
              }
              
              [[[UIAlertView alloc] initWithTitle:@"Genial!"
                                          message:@"Tu noticia se ha enviado correctamente"
                                         delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles: nil] show];
              
          } else {
              switch (error.code) {
                  case -1302:{
                      UIAlertView *noDataAlert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                            message:@"Por favor, comprueba que los campos \"Titulo\" y \"Noticia\" han sido completados."
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles: nil];
                      [noDataAlert show];
                      
                      break;
                  }
                  default:
                      break;
              }
              NSLog(@"Error %@", error);
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
          }
          [self hideLoadingView];
      }];
}

- (void) readBlobURLForBlobName: (NSString *) blobName inContainer: (NSString *)containerName forImage: (UIImage *) image{
    NSDictionary *parameters = @{@"containerName" : containerName, @"blobName" : blobName};
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self.client invokeAPI:@"getbloburlfromauthorscontainer"
                      body:nil
                HTTPMethod:@"GET"
                parameters:parameters
                   headers:nil
                completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                    if (!error) {
                        NSLog(@"resultado --> %@", result);
                        
                        NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
                        [self uploadPhotoToAzureStorageWithData:imageData toURL:[NSURL URLWithString:result[@"sasUrl"]]];
                    }else{
                        NSLog(@"error --> %@", error);
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    }
                }];
}

- (void) uploadPhotoToAzureStorageWithData: (NSData *) imageData toURL: (NSURL *) sasURL{
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"api-key" : AZUREMOBILESERVICE_APPKEY};
    
    NSURLSession *upLoadSession = [NSURLSession sessionWithConfiguration:config
                                                                delegate:nil
                                                           delegateQueue:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:sasURL
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:60.0];
    
    [request setHTTPMethod:@"PUT"];
    [request addValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:imageData];
    
    self.uploadTask = [upLoadSession dataTaskWithRequest:request
                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                           if (!error) {
                                               NSLog(@"Response: %@", response);
                                           } else {
                                               // alert for error saving / updating note
                                               NSLog(@"Error: %@", error);
                                           }
                                           [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                       }];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self.uploadTask resume];
}

#pragma mark - Location

- (void) askForLocationPermissions{
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
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
    }
}

- (void) getUserLocation{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if ([CLLocationManager locationServicesEnabled]) {
        if (status == kCLAuthorizationStatusNotDetermined) {
//            [self.locationManager startUpdatingLocation];
            self.locationManager.delegate = self;
        }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
            self.locationManager = [[CLLocationManager alloc] init];
            if (!self.locationManager.delegate) {
                self.locationManager.delegate = self;
            }
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            [self.locationManager startUpdatingLocation];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager
      didUpdateLocations:(NSArray *)locations{
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    self.location = [locations lastObject];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSString *source;
    switch (buttonIndex) {
        case 0:
            source = CAMERA;
            [self takePicture: source];
            break;
        case 1:
            source = ROLL;
            [self takePicture: source];
            break;
        case 2:
            source = ALBUM;
            [self takePicture: source];
            break;
        default:
            self.photoData = nil;
            [self syncroPhotoImage];
            break;
    }
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *dictBuilder = [GAIDictionaryBuilder createEventWithCategory:@"writter"
                                                                               action:@"takePhoto"
                                                                                label:source
                                                                                value:nil];
    [tracker send: [dictBuilder build]];
    
}

    
#pragma mark - Image
- (void) takePicture: (NSString *) type{
    // Creamos un UIImagePickerController
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    // -------------- Lo configuramos ---------------
    if ([type isEqualToString:CAMERA]) {
        // Compruebo si el dispositivo tiene camara
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            // Uso la camara
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else{
            // Tiro de la galeria
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    } else if ([type isEqualToString:ROLL]){
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.modalPresentationStyle = UIModalPresentationFormSheet;
    } else{
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    // Asigno el delegado
    picker.delegate = self;
    
    // Customizo la transicion del controlador modal
    // picker.modalPresentationStyle -> forma en la que se va a presentar
    //    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // picker.modalTransitionStyle -> animacion que se va a usar al hacer la transicion
    // ojo si se usa "UIModalTransitionStylePartialCurl" -> No se va a llamar a viewWillDisappear ni a viewWillAppear cuando se produzca la transicion
    picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // Lo muetro de forma modal
    [self presentViewController:picker
                       animated:YES
                     completion:^{
                         // Esto se va a ejecutar cuando termine la animacion que muestra al picker
                     }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    // ¡OJO! Pico de memoria asegurado, especialmente en dispositivos "antiguos" (iPhone 4S, iPhone 5), por culpa de la UIImage que se recibe en el diccionario
    // Sacamos la UIImage del diccionario
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // La guardo en el modelo
    self.photoData = UIImageJPEGRepresentation(img, 1);
    [self syncroPhotoImage];
    
    // Quito de enmedio al picker
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 // Se ejecutará cuando se haya ocultado del todo
                             }];
    
    // Usar self.presentingViewController si no existe un protocolo de delegado. No hace falta montar uno solo para ocultar la modal.
}

@end
