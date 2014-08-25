//
//  iTunesTableViewController.m
//  RSSFeediTunes
//
//  Created by Makeba Zoe Malcolm on 23/08/14.
//  Copyright (c) 2014 Zoe Malcolm. All rights reserved.
//

#import "iTunesTableViewController.h"

@interface iTunesTableViewController ()

@end

@implementation iTunesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Reload"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(startConnection)];
    
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}
-(void)viewWillAppear:(BOOL)animated
{
    [self startConnection];
}

-(void)startConnection
{
    NSURL *feedURL = [[NSURL alloc]initWithString:@"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topgrossingapplications/sf=143441/limit=25/json"];
    
    NSMutableURLRequest *feedRequest = [[NSMutableURLRequest alloc] initWithURL:feedURL];
    
    AFHTTPRequestOperation *feedOperation = [[AFHTTPRequestOperation alloc]initWithRequest:feedRequest];
    feedOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [feedOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.iTunesFeed = (NSDictionary *)responseObject;
        [self fromResponsetoITunesArray];
        self.title = @"Top Apps";
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *errorView = [[UIAlertView alloc]initWithTitle:@"Error retrieving Feed"
                                                           message:[error localizedDescription]
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles: nil];
        
        [errorView show];
    }];
    
    [feedOperation start];

}

-(void)fromResponsetoITunesArray
{
    self.iTunesArray = [[NSMutableArray alloc]init];
    
    NSDictionary *feedDict = [self.iTunesFeed valueForKey:@"feed"];

    NSArray *entries = [feedDict valueForKey:@"entry"];
    
    for (NSDictionary *entry in entries) {
        
        NSDictionary *nameDict = [entry valueForKey:@"im:name"];
        NSString *name = [nameDict valueForKey:@"label"];
        
        NSArray *imageArray = [entry valueForKey:@"im:image"];
        NSDictionary *imageDict = imageArray[0];
        NSString *imageURL = [imageDict valueForKey:@"label"];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        
        NSMutableDictionary *appDictionary = [[NSMutableDictionary alloc]init];
        [appDictionary setValue:name forKey:@"name"];
        [appDictionary setValue:imageData forKey:@"imageData"];
        
        [self.iTunesArray addObject:appDictionary];
        
    }
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.iTunesArray count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSDictionary *appInfo = self.iTunesArray[indexPath.row];
    NSData *imageData = [appInfo valueForKey:@"imageData"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"#%i %@", indexPath.row + 1, [appInfo valueForKey:@"name"]];
    [cell.imageView setImage:[UIImage imageWithData:imageData]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


@end
