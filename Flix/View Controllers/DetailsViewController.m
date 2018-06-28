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

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

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
    
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text  = self.movie[@"overview"];
    
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
    
    //adjust scrollview
    CGFloat maxHeight = self.synopsisLabel.frame.origin.y + self.synopsisLabel.frame.size.height + 10;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, maxHeight);
    
     self.navigationItem.title=self.movie[@"title"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //send the video ID to the trailer page
    
    TrailerViewController *trailerViewController = [segue destinationViewController];
    trailerViewController.movieID = self.movie[@"id"];
}


@end
