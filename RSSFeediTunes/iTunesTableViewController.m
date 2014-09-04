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

@synthesize iTunesArray, imageDownloadQueue, imageCache;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    

}
-(void)viewWillAppear:(BOOL)animated
{
    
    imageCache = [[NSCache alloc] init];
    imageCache.countLimit = 50;
    
    imageDownloadQueue = [[NSOperationQueue alloc]init];
    [self startConnection];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [imageDownloadQueue cancelAllOperations];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [iTunesArray count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    /* Set text for TableViewCell */
    
    FeedItem *appDetail = (FeedItem *) iTunesArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"#%i %@", indexPath.row + 1, appDetail.name];
    
    /* Add image asynchronously */
    
    UIImage *cachedImage = [imageCache objectForKey:appDetail.imageURL];
    
    if (cachedImage){
        cell.imageView.image = cachedImage;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"blanksquare.jpg"];
        
       [imageDownloadQueue addOperationWithBlock:^{
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appDetail.imageURL]];
            UIImage *image    = nil;
            
            if (imageData) image = [UIImage imageWithData:imageData];
            
            if (image){
                
                [imageCache setObject:image forKey:appDetail.imageURL];
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                UITableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];
                if (updateCell) cell.imageView.image = [UIImage imageWithData:imageData];

            }];
            
        }];
        
    }
    
        return cell;
}

#pragma mark Data Methods

-(void)startConnection
{
    
    NSURL *feedURL = [[NSURL alloc]initWithString:@"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topgrossingapplications/sf=143441/limit=25/json"];
    
    NSMutableURLRequest *feedRequest = [[NSMutableURLRequest alloc] initWithURL:feedURL];
    
    AFHTTPRequestOperation *feedOperation = [[AFHTTPRequestOperation alloc]initWithRequest:feedRequest];
    feedOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [feedOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dataFeed = (NSDictionary *)responseObject;
        [self fromResponsetoDataArray:dataFeed];
        
        [self.tableView reloadData];

        
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

-(void)fromResponsetoDataArray:(NSDictionary*)dataFeed
{
   iTunesArray = [[NSMutableArray alloc]init];
    
    NSDictionary *feedDict = [dataFeed valueForKey:@"feed"];
    
    NSArray *entries = [feedDict valueForKey:@"entry"];
    
    for (NSDictionary *entry in entries) {
        
        NSDictionary *nameDict = [entry valueForKey:@"im:name"];
        NSString *name = [nameDict valueForKey:@"label"];
        
        NSArray *imageArray = [entry valueForKey:@"im:image"];
        NSDictionary *imageDict = imageArray[0];
        NSString *imageURL = [imageDict valueForKey:@"label"];
        
        FeedItem *appRecord = [[FeedItem alloc]init];
        appRecord.name = name;
        appRecord.imageURL = imageURL;

        
        [iTunesArray addObject:appRecord];
        
    }
    
}



@end
