//
//  FLGDetalleAllScoopViewController.h
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 1/5/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

@import UIKit;
@class Scoop;
#import "GAITrackedViewController.h"

@interface FLGDetalleAllScoopViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UITextField *authorView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *puntuacionMediaView;
@property (weak, nonatomic) IBOutlet UITextField *scoreView;

@property (nonatomic, strong) Scoop *scoop;

- (id) initWithModel: (Scoop *) scoop;

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)sendScore:(id)sender;

@end
