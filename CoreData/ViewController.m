//
//  ViewController.m
//  CoreData
//
//  Created by Thomson on 16/1/28.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "ViewController.h"
#import "DataStorage.h"
#import "SimpleModel.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nicknameText;
@property (weak, nonatomic) IBOutlet UILabel *sexText;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    DataStorage *storage = [[DataStorage alloc] init];

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    dictionary[UserIdKey] = @"100";
    dictionary[AvatarKey] = @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg";
    dictionary[SexKey] = @(0);
    dictionary[NicknameKey] = @"Thomson";

    [storage saveModelWithDictionary:dictionary];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    DataStorage *storage = [[DataStorage alloc] init];

    SimpleModel *model = [storage modelWithUid:@"100"];

    self.nicknameText.text = model.nickname ? model.nickname : @"";
    self.sexText.text = model.sex.integerValue == 1 ? @"Male" : @"Female";

    if (model.avatar)
    {
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:model.avatar]]
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

                        if (data)
                        {
                            UIImage *image = [UIImage imageWithData:data scale:1];
                            dispatch_async(dispatch_get_main_queue(), ^{

                                self.avatarView.image = image;
                            });
                        }
                   }] resume];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
