//
//  TrailerViewController.m
//  Flix
//
//  Created by Michael Abelar on 6/28/18.
//  Copyright © 2018 Michael Abelar. All rights reserved.
//

#import "TrailerViewController.h"

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", @"https://api.themoviedb.org/3/movie/", self.movieID ,@"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    //make request to get trailer
    //get from url
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
            
            NSArray *videosList = dataDictionary[@"results"];
            NSString *videoKey = videosList[0][@"key"];
            NSString *youTubeLink = [NSString stringWithFormat:@"%@%@", @"https://www.youtube.com/watch?v=", videoKey];
            //set web view
            NSURL *trailerURL = [NSURL URLWithString:youTubeLink];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:trailerURL];
            [self.webView loadRequest:urlRequest];
            
        }
        
    }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
