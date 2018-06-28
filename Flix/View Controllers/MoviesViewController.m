//
//  MoviesViewController.m
//  Flix
//
//  Created by Michael Abelar on 6/27/18.
//  Copyright © 2018 Michael Abelar. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //table view init
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchMovies];
    
    //create it so pulling up will refresh the code
    self.refreshControl = [[UIRefreshControl alloc ] init];
    //what to do when refresh
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    //put the refresh in table
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self.indicatorView startAnimating];
}

-(void)fetchMovies {
    //get from url
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            
            // TODO: Store the movies in a property to use elsewhere
            // TODO: Reload your table view data
            self.movies = dataDictionary[@"results"];
            [self.tableView reloadData];
            [self.indicatorView stopAnimating];
            
            
        }
        //stop refresh
        [self.refreshControl endRefreshing];
    }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //need to create cell for base
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    cell.titleLabel.text = self.movies[indexPath.row][@"title"];
    cell.synopsisLabel.text = self.movies[indexPath.row][@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = self.movies[indexPath.row][@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    [cell.posterView setImageWithURL:posterURL];
    
    return cell;
}

#pragma mark - Navigation

//this function passes data to the next view controller
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //sender if the cell that got clicked
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    //name of the other class
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}




@end
