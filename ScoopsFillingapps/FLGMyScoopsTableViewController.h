//
//  FLGMyScoopsTableViewController.h
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 30/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLGDetalleMyScoopViewController.h"
#import "GAITrackedViewController.h"

@interface FLGMyScoopsTableViewController : GAITrackedViewController<UITableViewDelegate, UITableViewDataSource, FLGDetalleMyScoopViewControllerDelegate>


- (IBAction)newsFilter:(id)sender;

@end
