//
//  ReviewsViewController.m
//  Flix
//
//  Created by Michael Abelar on 6/28/18.
//  Copyright © 2018 Michael Abelar. All rights reserved.
//

#import "ReviewsViewController.h"
#import "ReviewCell.h"
#import "UIImageView+AFNetworking.h"

@interface ReviewsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *reviews;
@end

@implementation ReviewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", @"https://api.themoviedb.org/3/movie/", self.movieID, @"/reviews?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSString *errorMSG = [error localizedDescription];
            //check for no internet connection
            if (!([errorMSG rangeOfString:@"Internet"].location == NSNotFound)) {
                // create an alert notifiying the user that they are not connected to internet
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies"
                                                                               message:@"The internet connection appears to be offline"
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {}];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:^{}];
            }
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            self.reviews = dataDictionary[@"results"];
            
            //no reviews
            if (self.reviews.count == 0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Reviews"
                                                                               message:@"There are no reviews for this movie yet."
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {}];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:^{}];
            }
            
            [self.tableView reloadData];
            
        
        }
        
    }];
    [task resume];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reviews.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];
    cell.authorLabel.text = [NSString stringWithFormat:@"%@%@", @"Author: ", self.reviews[indexPath.row][@"author"]];
    cell.descriptionLabel.text = self.reviews[indexPath.row][@"content"];
    return cell;
}

@end
