//
//  Scoop.h
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 29/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

@import UIKit;
@import Foundation;
@import CoreLocation;

@interface Scoop : NSObject

- (id) initWithTitle:(NSString *) aTitle
           photoData:(NSData *) aPhotoData
                text:(NSString *) aText
              author:(NSString *) anAuthor
            authorID:(NSString *) anAuthorID
               coord:(CLLocationCoordinate2D) aCoord
              status:(NSString *) aStatus
               score:(CGFloat) aScore
             scoopId:(NSString *) aScoopId
        photoName:(NSString *) aPhotoName;

@property (readonly) NSString *title;
@property (readonly) NSString *text;
@property (readonly) NSString *author;
@property (readonly) NSString *authorID;
@property (readonly) CLLocationCoordinate2D coors;
@property (readonly) NSData *photoData;
@property (readonly) NSDate *dateCreated;
@property (strong, nonatomic) NSString *status;
@property (readonly) NSString *scoopId;
@property (nonatomic) CGFloat score;
@property (readonly) NSString *photoName;


@end