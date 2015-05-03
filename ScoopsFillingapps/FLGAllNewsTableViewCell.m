//
//  FLGAllNewsTableViewCell.m
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 1/5/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

#import "FLGAllNewsTableViewCell.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "SharedKeys.h"

#import "Scoop.h"

@interface FLGAllNewsTableViewCell()
@property (strong, nonatomic) MSClient *client;
@end

@implementation FLGAllNewsTableViewCell

+ (NSString*) cellId{
    return NSStringFromClass(self);
}

+ (CGFloat) height{
    return 94;
}

- (void)awakeFromNib {
    
    [self warmUpAzure];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.imagen.layer.borderWidth = 0.5;
    self.imagen.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.imagen.layer.cornerRadius = 5;
    self.imagen.layer.masksToBounds = YES;
    
//    self.imagen.image = [UIImage imageNamed:@"no_image"];
}

- (void)prepareForReuse{
    
    self.imagen.image = nil;
    self.titleNews.text = @" ";
    self.author.text = @" ";
}

- (void)setScoop:(Scoop *)scoop{
    
    _scoop = scoop;

    [self.activityView startAnimating];
    
    self.titleNews.text = _scoop.title;
    self.author.text = _scoop.author;
    
    [self readBlobURLForBlobName:[_scoop.photoName stringByReplacingOccurrencesOfString:@".jpg" withString:@"_thumb.jpg"] inContainer:_scoop.authorID];
}

- (void) warmUpAzure{
    self.client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                      applicationKey:AZUREMOBILESERVICE_APPKEY];
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
                                if (image) {
                                    self.imagen.image = image;
                                }else{
                                    self.imagen.image = [UIImage imageNamed:@"no_image"];
                                }
                            }else{
                                self.imagen.image = [UIImage imageNamed:@"no_image"];
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
            NSData *imageData = [NSData dataWithContentsOfURL:location];
            UIImage *image;
            if (imageData) {
                image = [UIImage imageWithData:imageData];
            }else{
                image = [UIImage imageNamed:@"no_image"];
            }
            completion(image, error);
        }
    }];
    [downloadTask resume];
}

@end
