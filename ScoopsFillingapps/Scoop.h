//
//  Scoop.h
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 29/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

@import Foundation;
@import CoreLocation;

@interface Scoop : NSObject

- (id) initWithTitle:(NSString *) aTitle
               photo:(NSData *) aPhoto
                text:(NSString *) aText
              author:(NSString *) anAuthor
               coord:(CLLocationCoordinate2D) aCoord
              status: (NSString *) aStatus
              score: (NSString *) aScore
              scoopId: (NSString *) scoopId;

@property (readonly) NSString *title;
@property (readonly) NSString *text;
@property (readonly) NSString *author;
@property (readonly) CLLocationCoordinate2D coors;
@property (readonly) NSData *image;
@property (readonly) NSDate *dateCreated;
@property (readonly) NSString *status;
@property (readonly) NSString *scoopId;
@property (readonly) NSString *score;


@end