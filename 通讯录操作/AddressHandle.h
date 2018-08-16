//
//  AddressHandle.h
//  通讯录操作
//
//  Created by 李贻佳 on 16/12/28.
//  Copyright © 2016年 liyijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressHandle : NSObject
+(AddressHandle *)shareManage;
/**
 通讯录授权和查询用户
 */
- (void)fetchAddressBookOnIOS9AndLater:(void (^)(NSArray *data))Source;



/**
 删除联系人

 @param name 删除指定联系人
 @param alldelete 如yes则删除所有联系人
 @return yes为删除成功
 */
-(BOOL)deleteName:(NSString *)name orAlldelete:(BOOL)alldelete;

/**
 新增一个联系人

 @param name 联系人姓名
 @param num 联系人电话号码
 */
-(void)creatPeopleName:(NSString *)name AndphoneNum:(NSString *)num;

@end
