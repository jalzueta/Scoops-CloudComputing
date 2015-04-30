//
//  FLGAllScoopCollectionViewController.m
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 30/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

#import "FLGAllScoopCollectionViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "SharedKeys.h"
#import "Scoop.h"
#import "NewsTableViewCell.h"

#define CELLIDENT @"NewsTableViewCell"

@interface FLGAllScoopCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *model;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FLGAllScoopCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Register cell classes
    [self registerNib];
    
    // Set height for all cells
    self.tableView.rowHeight = [NewsTableViewCell height];
    
    self.model = [@[]mutableCopy];
    [self populateModelFromAzure];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.count;
}


#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:[NewsTableViewCell cellId] forIndexPath:indexPath];
    
    cell.scoop = [self.model objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - modelo
- (void)populateModelFromAzure{
    
    MSClient *  client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                             applicationKey:AZUREMOBILESERVICE_APPKEY];
    
    MSTable *table = [client tableWithName:@"news"];
    
    MSQuery *queryModel = [[MSQuery alloc]initWithTable:table];
    [queryModel readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        
        
        
        for (id item in items) {
            NSLog(@"item -> %@", item);
            Scoop *scoop = [[Scoop alloc]initWithTitle:item[@"title"]
                                                 photo:nil
                                                  text:item[@"text"]
                                                author:item[@"author"]
                                                 coord:CLLocationCoordinate2DMake([item[@"latitude"] doubleValue], [item[@"longitude"] doubleValue])
                                                status:item[@"status"]];
                            
            [self.model addObject:scoop];
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - Utils
-(void) registerNib{
    
    UINib *nib = [UINib nibWithNibName:CELLIDENT
                                bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:[NewsTableViewCell cellId]];
}

@end
