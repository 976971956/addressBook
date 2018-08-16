//
//  AddressHandle.m
//  通讯录操作
//
//  Created by 李贻佳 on 16/12/28.
//  Copyright © 2016年 liyijia. All rights reserved.
//

#import "AddressHandle.h"
#import <AddressBook/AddressBook.h>
#import <ContactsUI/ContactsUI.h>
#import <AddressBookUI/AddressBookUI.h>

@implementation AddressHandle
+(AddressHandle *)shareManage
{
    static AddressHandle *address = nil;
    static dispatch_once_t manage;
    dispatch_once(&manage, ^{
        address = [[self alloc]init];
    });
    return address;
}


- (void)fetchAddressBookOnIOS9AndLater:(void (^)(NSArray *data))Source{
    
    //创建CNContactStore对象
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    //首次访问需用户授权
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {//首次访问通讯录
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error){
                if (granted) {//允许
                    NSLog(@"已授权访问通讯录");
                    NSArray *contacts = [self fetchContactWithContactStore:contactStore];//访问通讯录
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //----------------主线程 更新 UI-----------------
//                        NSLog(@"所有用户:%@", contacts);
                        Source(contacts);
                        
                        
                    });
                }else{//拒绝
                    NSLog(@"拒绝访问通讯录");
                }
            }else{
                NSLog(@"发生错误!");
            }
        }];
    }else{//非首次访问通讯录
        NSArray *contacts = [self fetchContactWithContactStore:contactStore];//访问通讯录
        dispatch_async(dispatch_get_main_queue(), ^{
            //----------------主线程 更新 UI-----------------
            NSLog(@"contacts:%@", contacts);
            
            
            
        });
    }
}

- (NSMutableArray *)fetchContactWithContactStore:(CNContactStore *)contactStore{
    //判断访问权限
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {//有权限访问
        NSError *error = nil;
        //创建数组,必须遵守CNKeyDescriptor协议,放入相应的字符串常量来获取对应的联系人信息
        NSArray <id<CNKeyDescriptor>> *keysToFetch = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey];
        //获取通讯录数组
        NSArray<CNContact*> *arr = [contactStore unifiedContactsMatchingPredicate:nil keysToFetch:keysToFetch error:&error];
        if (!error) {
            NSMutableArray *contacts = [NSMutableArray array];
            for (int i = 0; i < arr.count; i++) {
                CNContact *contact = arr[i];
                NSString *givenName = contact.givenName;
                NSString *familyName = contact.familyName;
                NSString *phoneNumber = ((CNPhoneNumber *)(contact.phoneNumbers.lastObject.value)).stringValue;
                if (phoneNumber==nil) {
                    phoneNumber = @"";
                }
                [contacts addObject:@{@"name": [givenName stringByAppendingString:familyName], @"phoneNumber": phoneNumber}];
            
            }
            return contacts;
        }else {
            return nil;
        }
    }else{//无权限访问
        NSLog(@"无权限访问通讯录");
        return nil;
    }
}
-(BOOL)deleteName:(NSString *)name orAlldelete:(BOOL)alldelete
{
    BOOL les;
    // 初始化并创建通讯录对象，记得释放内存
    ABAddressBookRef addressBook = ABAddressBookCreate();
    // 获取通讯录中所有的联系人
    NSArray *array = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    // 遍历所有的联系人并删除(这里只删除姓名为张三的)
    for (id obj in array) {
        ABRecordRef people = (__bridge ABRecordRef)obj;
        if (alldelete) {
            les = ABAddressBookRemoveRecord(addressBook, people, NULL);
            return les;
        }

        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(people, kABPersonFirstNameProperty);
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(people, kABPersonLastNameProperty);
        if (lastName==nil) {
            lastName = @"";
        }
        if (firstName==nil) {
            firstName = @"";
        }
        NSString *namelet = [lastName stringByAppendingString:firstName];
        
        if ([name isEqualToString:namelet]) {
            les = ABAddressBookRemoveRecord(addressBook, people, NULL);
        }
    }
   
    // 保存修改的通讯录对象
    ABAddressBookSave(addressBook, NULL);
    // 释放通讯录对象的内存
    if (addressBook) {
        CFRelease(addressBook);
    }
     return les;
}
-(void)creatPeopleName:(NSString *)name AndphoneNum:(NSString *)num;
{
    // 初始化一个ABAddressBookRef对象，使用完之后需要进行释放，
    // 这里使用CFRelease进行释放
    // 相当于通讯录的一个引用
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    // 新建一个联系人
    // ABRecordRef是一个属性的集合，相当于通讯录中联系人的对象
    // 联系人对象的属性分为两种：
    // 只拥有唯一值的属性和多值的属性。
    // 唯一值的属性包括：姓氏、名字、生日等。
    // 多值的属性包括:电话号码、邮箱等。
    ABRecordRef person = ABPersonCreate();
    NSString *firstName = [name substringFromIndex:1];
    NSString *lastName = [name substringToIndex:1];
    NSDate *birthday = [NSDate date];
    // 电话号码数组
    NSArray *phones = [NSArray arrayWithObjects:num, nil];
    // 电话号码对应的名称
    NSArray *labels = [NSArray arrayWithObjects:@"个人电话", nil];
    // 保存到联系人对象中，每个属性都对应一个宏，例如：kABPersonFirstNameProperty
    // 设置firstName属性
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)firstName, NULL);
    // 设置lastName属性
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFStringRef) lastName, NULL);
    // 设置birthday属性
    ABRecordSetValue(person, kABPersonBirthdayProperty, (__bridge CFDateRef)birthday, NULL);
    // ABMultiValueRef类似是Objective-C中的NSMutableDictionary
    ABMultiValueRef mv = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    // 添加电话号码与其对应的名称内容
    for (int i = 0; i < [phones count]; i ++) {
        ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(mv, (__bridge CFStringRef)[phones objectAtIndex:i], (__bridge CFStringRef)[labels objectAtIndex:i], &mi);
    }
    // 设置phone属性
    ABRecordSetValue(person, kABPersonPhoneProperty, mv, NULL);
    // 释放该数组
    if (mv) {
        CFRelease(mv);
    }
    // 将新建的联系人添加到通讯录中
    ABAddressBookAddRecord(addressBook, person, NULL);
    // 保存通讯录数据
    ABAddressBookSave(addressBook, NULL);
    // 释放通讯录对象的引用
    if (addressBook) {
        CFRelease(addressBook);
    }
}
/*
 升到iOS10之后，需要设置权限的有：
 
 麦克风权限：Privacy - Microphone Usage Description 是否允许此App使用你的麦克风？
 
 相机权限： Privacy - Camera Usage Description 是否允许此App使用你的相机？
 
 相册权限： Privacy - Photo Library Usage Description 是否允许此App访问你的媒体资料库？
 
 通讯录权限： Privacy - Contacts Usage Description 是否允许此App访问你的通讯录？
 
 蓝牙权限：Privacy - Bluetooth Peripheral Usage Description 是否许允此App使用蓝牙？
 
 语音转文字权限：Privacy - Speech Recognition Usage Description 是否允许此App使用语音识别？
 
 日历权限：Privacy - Calendars Usage Description
 
 定位权限：Privacy - Location When In Use Usage Description
 
 定位权限: Privacy - Location Always Usage Description
 
 位置权限：Privacy - Location Usage Description
 
 媒体库权限：Privacy - Media Library Usage Description
 
 健康分享权限：Privacy - Health Share Usage Description
 
 健康更新权限：Privacy - Health Update Usage Description
 
 运动使用权限：Privacy - Motion Usage Description
 
 音乐权限：Privacy - Music Usage Description
 
 提醒使用权限：Privacy - Reminders Usage Description
 
 Siri使用权限：Privacy - Siri Usage Description
 
 电视供应商使用权限：Privacy - TV Provider Usage Description
 
 视频用户账号使用权限：Privacy - Video Subscriber Account Usage Description
 
 文／孤独雪域（简书作者）
 原文链接：http://www.jianshu.com/p/bfbed5b7fbc8
 著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。*/
@end
