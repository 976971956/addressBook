//
//  ViewController.m
//  通讯录操作
//
//  Created by 李贻佳 on 16/12/27.
//  Copyright © 2016年 liyijia. All rights reserved.
//

#import "ViewController.h"
#import "AddressHandle.h"
@interface ViewController ()
//指定删除的人
@property (strong, nonatomic) IBOutlet UITextField *deleteOnePeople;
@property (strong, nonatomic) IBOutlet UITextField *curname;
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UITextField *telephoneNumber;
@property (strong, nonatomic) IBOutlet UITextField *totelephonetext;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AddressHandle shareManage] fetchAddressBookOnIOS9AndLater:^(NSArray *data) {
        NSLog(@"%@",data);
    }];
}
//删除指定的人
- (IBAction)deleteOnepeopleClick:(id)sender {
    [self alters:NO];
}
//删除通讯录里所有人
- (IBAction)deleteAllPeople:(id)sender {
    [self alters:YES];
}
//拨打电话
- (IBAction)totelephonenum:(id)sender {
//    NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"tel:%@",self.totelephonetext.text];
//    // NSLog(@"str======%@",str);
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
    NSMutableString *str1=[[NSMutableString alloc] initWithFormat:@"tel:%@",self.totelephonetext.text];
    UIWebView *callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str1]]];
    [self.view addSubview:callWebview];
    
}
//新增用户
- (IBAction)AddPeople:(id)sender {
    NSString *names = [NSString stringWithFormat:@"%@%@",self.curname.text,self.name.text];
    [[AddressHandle shareManage] creatPeopleName:names AndphoneNum:self.telephoneNumber.text];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
-(void)alters:(BOOL)ret{
    NSString *messages = @"删除一个联系人";
    if (ret) {
        messages =@"你正在选择删除所有联系人，请慎重！如不删除请取消";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:messages preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"%@",self.deleteOnePeople.text);
        BOOL rets = [[AddressHandle shareManage] deleteName:self.deleteOnePeople.text orAlldelete:ret];
        NSLog(@"删除联系人%@",rets?@"成功":@"失败");
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消删除");

    }];
    [alertController addAction:okAction];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
