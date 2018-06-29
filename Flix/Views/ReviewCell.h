//
//  ReviewCell.h
//  Flix
//
//  Created by Michael Abelar on 6/28/18.
//  Copyright © 2018 Michael Abelar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
