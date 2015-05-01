//
//  FLGAllNewsTableViewCell.m
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 1/5/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

#import "FLGAllNewsTableViewCell.h"

#import "Scoop.h"

@implementation FLGAllNewsTableViewCell

+ (NSString*) cellId{
    return NSStringFromClass(self);
}

+ (CGFloat) height{
    return 94;
}

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    
    self.imagen.layer.borderWidth = 0.5;
    self.imagen.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.imagen.layer.cornerRadius = 5;
    self.imagen.layer.masksToBounds = YES;
}

- (void)prepareForReuse{
    
    self.imagen.image = nil;
    self.titleNews.text = @" ";
    self.author.text = @" ";
}

- (void)setScoop:(Scoop *)scoop{
    
    _scoop = scoop;
    
    if (!self.scoop.image) {
        self.imagen.image = [UIImage imageNamed:@"no_image"];
    }else{
        self.imagen.image = [UIImage imageWithData:_scoop.image];
    }
    self.titleNews.text = _scoop.title;
    self.author.text = _scoop.author;
}

@end
