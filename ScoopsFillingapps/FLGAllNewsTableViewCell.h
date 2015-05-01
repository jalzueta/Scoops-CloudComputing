//
//  FLGAllNewsTableViewCell.h
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 1/5/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

@import UIKit;
@class Scoop;

@interface FLGAllNewsTableViewCell : UITableViewCell

+ (NSString*) cellId;
+ (CGFloat) height;

@property (weak, nonatomic) IBOutlet UIImageView *imagen;
@property (weak, nonatomic) IBOutlet UILabel *titleNews;
@property (weak, nonatomic) IBOutlet UILabel *author;

@property (weak, nonatomic) Scoop *scoop;
@property (nonatomic) BOOL statusNew;

@end
