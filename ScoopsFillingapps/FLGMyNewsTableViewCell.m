//
//  FLGMyNewsTableViewCell.m
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 19/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import "FLGMyNewsTableViewCell.h"

#import "Scoop.h"


@interface FLGMyNewsTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imagen;
@property (weak, nonatomic) IBOutlet UILabel *titleNews;
@property (weak, nonatomic) IBOutlet UILabel *status;

@end

@implementation FLGMyNewsTableViewCell

+ (NSString*) cellId{
    return NSStringFromClass(self);
}

+ (CGFloat) height{
    return 94;
}

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}

- (void)prepareForReuse{
    
    self.imagen.image = nil;
    self.titleNews.text = @" ";
    self.status.text = @" ";
}

- (void)setScoop:(Scoop *)scoop{
    
    _scoop = scoop;
    
    if (!self.scoop.image) {
        self.imagen.image = [UIImage imageNamed:@"no_image"];
    }else{
        self.imagen.image = [UIImage imageWithData:_scoop.image];
    }
    self.titleNews.text = _scoop.title;
    self.status.text = _scoop.status;
}

@end
