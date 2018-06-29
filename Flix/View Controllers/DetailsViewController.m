//
//  DetailsViewController.m
//  Flix
//
//  Created by Michael Abelar on 6/27/18.
//  Copyright © 2018 Michael Abelar. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"
#import "ReviewsViewController.h"

//macro from https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIButton *trailerLabel;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;


@end

@implementation DetailsViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    //sets alpha of images to 0 for a fade effect
    self.posterView.alpha = 0.0;
    self.backdropView.alpha = 0.0;
    //poster image
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = self.movie[@"poster_path"];
    if (posterURLString != (NSString *)[NSNull null]) {
        NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
        NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
        [self.posterView setImageWithURL:posterURL];
        [UIView animateWithDuration:0.6 animations:^{
            self.posterView.alpha = 1.0;
        }];
    }
    
    //backdrop
    NSString *imageSmall = @"https://image.tmdb.org/t/p/w200";
    NSString *imageLarge = @"https://image.tmdb.org/t/p/w500";
    NSString *backdropURLString = self.movie[@"backdrop_path"];
    if (backdropURLString != (NSString *)[NSNull null]) {
        //load low res then high res
        NSString *backdropSmall = [imageSmall stringByAppendingString:backdropURLString];
        NSString *backdropLarge = [imageLarge stringByAppendingString:backdropURLString];
        NSURL *backdropSmallURL = [NSURL URLWithString:backdropSmall];
        NSURL *backdropLargeURL = [NSURL URLWithString:backdropLarge];
        
        NSURLRequest *requestSmall = [NSURLRequest requestWithURL:backdropSmallURL];
        NSURLRequest *requestLarge = [NSURLRequest requestWithURL:backdropLargeURL];

        [self.backdropView setImageWithURLRequest:requestSmall placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
           self.backdropView.alpha = 0.0;
           self.backdropView.image = smallImage;
           
           [UIView animateWithDuration:0.3
                            animations:^{
                                
                                self.backdropView.alpha = 1.0;
                                
                            } completion:^(BOOL finished) {
                                // The AFNetworking ImageView Category only allows one request to be sent at a time
                                // per ImageView. This code must be in the completion block.
                                [self.backdropView setImageWithURLRequest:requestLarge
                                                          placeholderImage:smallImage
                                                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                                                       self.backdropView.image = largeImage;
                                                                   }
                                                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
                            }];
       }
       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
    }
    
    NSLog(@"%@", self.movie[@"runtime"]);
    
    
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text  = self.movie[@"overview"];
    self.ratingLabel.text = [NSString stringWithFormat:@"%@%@%@", @"Rating:   ", self.movie[@"vote_average"], @" / 10.0"];
    self.date.text = [NSString stringWithFormat:@"%@%@", @"Released: ", self.movie[@"release_date"]];
    
    //set button text depending if movie is in favorites
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *favorites = [userDefaults objectForKey:@"favoriteMovies"];
    BOOL contains = NO;
    for (NSDictionary *movie in favorites) {
        if (movie[@"id"] == self.movie[@"id"]) {
            contains = YES;
            break;
        }
    }
    if (contains) {
        [self.favoriteButton setTitle:@"Unfavorite Movie" forState:UIControlStateNormal];
    }
    
    
    
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
    
    //adjust scrollview
    CGFloat maxHeight = self.synopsisLabel.frame.origin.y + self.synopsisLabel.frame.size.height + 10;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, maxHeight);
    
     self.navigationItem.title=self.movie[@"title"];
    

}

//pressing the favorite movie button 
- (IBAction)favoriteMovieTap:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *favorites = [userDefaults objectForKey:@"favoriteMovies"];
    NSDictionary *movie = self.movie;
    BOOL contains = NO;
    for (NSDictionary *movie in favorites) {
        if (movie[@"id"] == self.movie[@"id"]) {
            contains = YES;
            break;
        }
    }
    if (contains) {
        //remove from array
        NSMutableArray * tempArray = [favorites mutableCopy];
        [tempArray removeObject:movie];
        favorites = [tempArray copy];
        //commit data
        [userDefaults setObject:favorites forKey:@"favoriteMovies"];
        [userDefaults synchronize];
        [self.favoriteButton setTitle:@"Favorite Movie" forState:UIControlStateNormal];
    }
    else {
        //add entry
        NSMutableArray * tempArray = [favorites mutableCopy];
        if (tempArray == nil) {
            tempArray = [[NSMutableArray alloc] init];
        }
        [tempArray addObject:movie];
        favorites = [tempArray copy];
        //commit to mem
        [userDefaults setObject:favorites forKey:@"favoriteMovies"];
        [userDefaults synchronize];
        [self.favoriteButton setTitle:@"Unfavorite Movie" forState:UIControlStateNormal];
    }
    NSLog(@"%@", favorites);
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //send the video ID to the trailer page
    
    TrailerViewController *trailerViewController = [segue destinationViewController];
    trailerViewController.movieID = self.movie[@"id"];
    
    ReviewsViewController *reviewsViewController = [segue destinationViewController];
    reviewsViewController.movieID = self.movie[@"id"];
}


@end
