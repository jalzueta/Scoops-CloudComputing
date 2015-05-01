//
//  FLGAllNewsTableViewCell.h
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 19/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>



@class Scoop;

@interface FLGMyNewsTableViewCell : UITableViewCell

+ (NSString*) cellId;
+ (CGFloat) height;

@property (weak, nonatomic) Scoop *scoop;
@property (nonatomic) BOOL statusNew;


@end
