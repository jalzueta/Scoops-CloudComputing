//
//  FLGMyScoopsTableViewController.m
//  ScoopsFillingapps
//
//  Created by Javi Alzueta on 30/4/15.
//  Copyright (c) 2015 FillinGAPPs. All rights reserved.
//

#import "FLGMyScoopsTableViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "SharedKeys.h"
#import "Scoop.h"
#import "FLGMyNewsTableViewCell.h"
#import "FLGDetalleMyScoopViewController.h"

#define CELLIDENT @"NewsTableViewCell"

@interface FLGMyScoopsTableViewController ()

@property (strong, nonatomic) MSClient *client;
@property (strong, nonatomic) NSMutableArray *model;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIControl *loadingVeloView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityView;

@end

@implementation FLGMyScoopsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:@selector(backToWriteNewScoop:)];
    
    [self warmUpAzure];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Register cell classes
    [self registerNib];
    
    // Set height for all cells
    self.tableView.rowHeight = [FLGMyNewsTableViewCell height];
    
    self.model = [@[]mutableCopy];
}

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.screenName = @"myScoops";
    
    self.loadingView.layer.cornerRadius = 10;
    
    [self hideLoadingView];
    [self populateModelWithMyPublishNews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void) backToWriteNewScoop: (id) sender{
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
    
    FLGMyNewsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:[FLGMyNewsTableViewCell cellId] forIndexPath:indexPath];
    
    cell.scoop = [self.model objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *dictBuilder = [GAIDictionaryBuilder createEventWithCategory:@"writter"
                                                                               action:@"openMyScoopDetail"
                                                                                label:nil
                                                                                value:nil];
    [tracker send: [dictBuilder build]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Scoop *scoop = [self.model objectAtIndex:indexPath.row];
    
    FLGDetalleMyScoopViewController *detalleScoopVC = [[FLGDetalleMyScoopViewController alloc] initWithModel: scoop];
    detalleScoopVC.delegate = self;
    [self.navigationController pushViewController:detalleScoopVC
                                         animated:YES];
}


#pragma mark - modelo

- (void) warmUpAzure{
    self.client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                             applicationKey:AZUREMOBILESERVICE_APPKEY];
}

- (void)populateModelWithMyPublishNews{
    
    [self populateModelWithStatus:@"published"]; //published
}

- (void)populateModelWithMyPendentNews{
    
    [self populateModelWithStatus:@"pending"]; //pending
}

- (void)populateModelWithMyUnpublishNews{
    
    [self populateModelWithStatus:@"notPublished"]; //notPublished
}

- (void) populateModelWithStatus: (NSString *) status{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self showLoadingView];
    
    [self.model removeAllObjects];
    
    NSString *authorID = [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"];
    NSDictionary *parameters = @{@"orderedBy" : @"__updatedAt", @"status" : status, @"authorID" : authorID};
    
    [self.client invokeAPI:@"readmynews"
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
                                                        photoData:nil
                                                             text:item[@"text"]
                                                           author:item[@"author"]
                                                         authorID:item[@"authorID"]
                                                            coord:CLLocationCoordinate2DMake([item[@"latitude"] doubleValue], [item[@"longitude"] doubleValue])
                                                           status:item[@"status"]
                                                            score:[item[@"score"] floatValue]
                                                          scoopId:item[@"id"]
                                                        photoName:item[@"image"]];
                       
                       [self.model addObject:scoop];
                   }
                   [self.tableView reloadData];
               }else{
                   NSLog(@"error --> %@", error);
               }
               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
               [self hideLoadingView];
           }];
}

#pragma mark - Utils

- (void) hideLoadingView{
    self.loadingVeloView.hidden = YES;
    [self.loadingActivityView stopAnimating];
}

- (void) showLoadingView{
    [self.loadingActivityView startAnimating];
    self.loadingVeloView.hidden = NO;
}

-(void) registerNib{
    
    UINib *nib = [UINib nibWithNibName:[FLGMyNewsTableViewCell cellId]
                                bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:[FLGMyNewsTableViewCell cellId]];
}

- (IBAction)newsFilter:(id)sender {
    
    UISegmentedControl *newsTypeSegment = (UISegmentedControl *) sender;
    switch (newsTypeSegment.selectedSegmentIndex) {
        case 0:
            [self populateModelWithMyPublishNews];
            break;
        case 1:
            [self populateModelWithMyPendentNews];
            break;
        case 2:
            [self populateModelWithMyUnpublishNews];
            break;
        default:
            break;
    }
}

#pragma mark - FLGDetalleMyScoopViewControllerDelegate

- (void) detalleMyScoopviewController:(FLGDetalleMyScoopViewController *)detalleMyScoopviewController didPublishNewWithId:(NSString *)scoopId{
    
    int indexToRemove = -1;
    for (int i=0; i<self.model.count; i++) {
        if ([[[self.model objectAtIndex:i] scoopId] isEqualToString:scoopId]) {
            indexToRemove = i;
            break;
        }
    }
    if (indexToRemove > 0) {
        [self.model removeObjectAtIndex:indexToRemove];
        [self.tableView reloadData];
    }
}

@end
