//
//  FLGAllScoopTableViewController.m
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 30/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

#import "FLGAllScoopTableViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "SharedKeys.h"
#import "Scoop.h"
#import "FLGAllNewsTableViewCell.h"
#import "FLGDetalleAllScoopViewController.h"

#define CELLIDENT @"NewsTableViewCell"

@interface FLGAllScoopTableViewController ()

@property (strong, nonatomic) NSMutableArray *model;
@property (strong, nonatomic) MSClient *client;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FLGAllScoopTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self warmUpAzure];
    
//    if (self.client.currentUser) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                               target:self
                                                                                               action:@selector(goBack:)];
//    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Register cell classes
    [self registerNib];
    
    // Set height for all cells
    self.tableView.rowHeight = [FLGAllNewsTableViewCell height];
    
    self.model = [@[]mutableCopy];
    [self populateModelFromAzureWithAPI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void) goBack: (id) sender{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FLGAllNewsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:[FLGAllNewsTableViewCell cellId] forIndexPath:indexPath];
    
    cell.scoop = [self.model objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Scoop *scoop = [self.model objectAtIndex:indexPath.row];
    
    FLGDetalleAllScoopViewController *detalleScoopVC = [[FLGDetalleAllScoopViewController alloc] initWithModel: scoop];
    [self.navigationController pushViewController:detalleScoopVC
                                         animated:YES];
}

#pragma mark - Azure

- (void) warmUpAzure{
    self.client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                      applicationKey:AZUREMOBILESERVICE_APPKEY];
}

- (void)populateModelFromAzureWithAPI{
    
    NSDictionary *parameters = @{@"orderedBy" : @"__updatedAt", @"status" : @"publicado"};
    
    [self.client invokeAPI:@"readallpartialnews"
                      body:nil
                HTTPMethod:@"GET"
                parameters:parameters
                   headers:nil
                completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                    if (!error) {
                        NSLog(@"resultado --> %@", result);
                        for (id item in result) {
                            NSLog(@"item -> %@", item);
                            Scoop *scoop = [[Scoop alloc]initWithTitle:item[@"title"]
                                                                 photo:nil
                                                                  text:item[@"text"]
                                                                author:item[@"author"]
                                                                 coord:CLLocationCoordinate2DMake([item[@"latitude"] doubleValue], [item[@"longitude"] doubleValue])
                                                                status:item[@"status"]
                                                                 score:item[@"score"]
                                                               scoopId:item[@"id"]];
                            
                            [self.model addObject:scoop];
                        }
                        [self.tableView reloadData];
                    }else{
                        NSLog(@"error --> %@", error);
                    }
                }];
}

#pragma mark - Utils
-(void) registerNib{
    
    UINib *nib = [UINib nibWithNibName:[FLGAllNewsTableViewCell cellId]
                                bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:[FLGAllNewsTableViewCell cellId]];
}

@end
