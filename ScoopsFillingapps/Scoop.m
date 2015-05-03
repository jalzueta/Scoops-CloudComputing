//
//  Scoop.m
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 29/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

#import "Scoop.h"

@interface Scoop ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *author;
@property (nonatomic) CLLocationCoordinate2D coors;
@property (nonatomic, strong) NSData *image;
@property (nonatomic, strong) NSDate *dateCreated;

@end


@implementation Scoop

- (id) initWithTitle:(NSString *) aTitle
           photoData:(NSData *) aPhotoData
                text:(NSString *) aText
              author:(NSString *) anAuthor
            authorID:(NSString *) anAuthorID
               coord:(CLLocationCoordinate2D) aCoord
              status:(NSString *) aStatus
               score: (CGFloat) aScore
             scoopId: (NSString *) aScoopId
           photoName:(NSString *) aPhotoName{
    
    if (self = [super init]) {
        _title = aTitle;
        _text = aText;
        _author = anAuthor;
        _authorID = anAuthorID;
        _coors = aCoord;
        _photoData = aPhotoData;
        _dateCreated = [NSDate date];
        _status = aStatus;
        _score = aScore;
        _scoopId = aScoopId;
        _photoName = aPhotoName;
    }
    return self;
}

#pragma mark - Overwritten

-(NSString*) description{
    return [NSString stringWithFormat:@"<%@ %@>", [self class], self.title];
}

- (BOOL)isEqual:(id)object{
    
    return [self.title isEqualToString:[object title]];
}

- (NSUInteger)hash{
    return [_title hash] ^ [_text hash];
}

@end
