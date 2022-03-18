//
//  ARUICalleeGroupCell.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import "ARUICalleeGroupCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ARUICommonUtil.h"

@interface ARUICalleeGroupCell ()

@property (nonatomic, strong) UIImageView *userIcon;

@end

@implementation ARUICalleeGroupCell

- (void)setModel:(CallUserModel *)model {
    _model = model;
    [self.userIcon sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[ARUICommonUtil getBundleImageWithName:@"userIcon"]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView];
        self.userIcon = imageView;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

@end
