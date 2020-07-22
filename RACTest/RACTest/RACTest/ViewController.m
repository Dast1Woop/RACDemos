//
//  ViewController.m
//  RACTest
//
//  Created by LongMa on 2020/7/22.
//  Copyright © 2020 hautu. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *gTF4User;

@property(nonatomic, strong) RACDisposable  *gDisBag;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testCombine];
    [self testTimeRelated];
}

- (void)dealloc{
    NSLog(@"%s", __FUNCTION__);
    
    [self.gDisBag dispose];
}

- (void)testCombine {
    //对文本输入框，最好写上skip:1,因为此处subscribeNext时，会执行一次subscribeNext内的代码
    [[self.gTF4User.rac_textSignal
      skip:1]
     subscribeNext:^(NSString *_Nullable x) {
        NSLog(@"tf come in:%@", x);
    }];
}

- (void)testTimeRelated{
    
    //    [self testTimeout];
    [self testTimer];
}

- (void)testTimer{
    __block int couteDown = 10;
    RACSignal *lSig = [RACSignal
                       interval:1 onScheduler:[RACScheduler mainThreadScheduler]];
    
    @weakify(self);
   self.gDisBag = [[lSig
                               filter:^BOOL(id  _Nullable value) {
        return couteDown > 0;
    }]
                              subscribeNext:^(id  _Nullable x) {
       @strongify(self);
        NSLog(@"x-%@",x);
        couteDown -= 1;
        
        if (1 == couteDown) {
            [self.gDisBag dispose];
        }
    }];
}

- (void)testTimeout{
    //timeout，如果timeout秒前没有发送完成或错误。在timeout秒后会自动发送错误
    RACSignal *lSig =
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@1];
        //        [subscriber sendCompleted];
        return nil;
    }] deliverOn:[RACScheduler scheduler]]
     timeout:2 onScheduler:[RACScheduler  mainThreadScheduler]];//scheduler:随机创建一个线程；mainThreadScheduler:主线程
    
    [lSig
     subscribeNext:^(id  _Nullable x) {
        NSLog(@"x:%@，thread:%@",x
              , [NSThread currentThread]);
    }];
    [lSig subscribeError:^(NSError * _Nullable error) {
        NSLog(@"error:%@，thread:%@"
              , error.localizedDescription
              , [NSThread currentThread]);
    }];
}

@end
