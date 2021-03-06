//
//  UserManager.m
//  YSProject
//
//  Created by cuiw on 15/6/8.
//  Copyright (c) 2015年 cuiw. All rights reserved.
//

#import "UserManager.h"
#define kUserManager @"ysuarch"

@implementation UserManager

+ (UserManager *)shareUserManager {
    static UserManager *_userManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userManager  = [[UserManager alloc] init];
    });
    return _userManager;
}

- (id)init {
    self = [super init];
    if (self) {
        _user = [[UserModel alloc] init];
        _userState = UserStateLogout;
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)enCoder {
    [enCoder encodeObject:_user forKey:@"UserManager_user"];
    [enCoder encodeObject:_sessionID forKey:@"UserManager_sessionID"];
    [enCoder encodeObject:_globalSessionID forKey:@"UserManager_globalSessionID"];
    [enCoder encodeInteger:_userState forKey:@"UserManager_userState"];
    [enCoder encodeObject:_loginName forKey:@"UserManager_loginName"];
    [enCoder encodeObject:_password forKey:@"UserManager_password"];
}

- (id)initWithCoder:(NSCoder *)deCoder {
    if (self = [super init]){
        self.user = [deCoder decodeObjectForKey:@"UserManager_user"];
        self.sessionID = [deCoder decodeObjectForKey:@"UserManager_sessionID"];
        self.globalSessionID = [deCoder decodeObjectForKey:@"UserManager_globalSessionID"];
        self.userState = (UserState)[deCoder decodeIntegerForKey:@"UserManager_userState"];
        self.loginName = [deCoder decodeObjectForKey:@"UserManager_loginName"];
        self.password = [deCoder decodeObjectForKey:@"UserManager_password"];
    }
    return self;
}

+ (UserManager *)currentUserManager {
    UserManager *userManager = [[CWNSFileUtil sharedInstance] getCustomModelFromUserDefatulesWithKey:kUserManager];
    if (!userManager) {
        userManager = [UserManager shareUserManager];
        [[CWNSFileUtil sharedInstance] setCustomModelToUserDefaults:userManager withKey:kUserManager];
    }
    return userManager;
}
- (void)synchronize {
    [[CWNSFileUtil sharedInstance] setCustomModelToUserDefaults:self withKey:kUserManager];
}

+ (BOOL)isLogin {
    UserManager *userManager = [UserManager currentUserManager];
    if (userManager.userState == UserStateLogin) {
        return YES;
    } else {
        return NO;
    }
}
+ (void)logout {
    UserManager *userManager = [[CWNSFileUtil sharedInstance] getCustomModelFromUserDefatulesWithKey:kUserManager];
    userManager.user = [[UserModel alloc] init];
    userManager.userState = UserStateLogout;
    userManager.loginName=nil;
    userManager.password=nil;
    userManager.sessionID = nil;
    [[CWNSFileUtil sharedInstance] setCustomModelToUserDefaults:userManager withKey:kUserManager];
}
@end
