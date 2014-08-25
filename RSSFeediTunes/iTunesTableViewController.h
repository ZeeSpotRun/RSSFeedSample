//
//  iTunesTableViewController.h
//  RSSFeediTunes
//
//  Created by Makeba Zoe Malcolm on 23/08/14.
//  Copyright (c) 2014 Zoe Malcolm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"


@interface iTunesTableViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *iTunesFeed;
@property (strong, nonatomic) NSMutableArray *iTunesArray;

@end
