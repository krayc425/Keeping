//
//  DBManager.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "DBManager.h"
#import <WatchConnectivity/WatchConnectivity.h>

#define GROUP_ID @"group.com.krayc.keeping"

@implementation DBManager 

static DBManager* _instance = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [DBManager shareInstance] ;
}

- (instancetype)init{
    self = [super init];
    if (self) {
//        [self establishWC];
        [self establishDB];
    }
    return self;
}

//- (void)establishWC{
    //Watch 链接
//    if ([WCSession isSupported]) {
//        WCSession *session = [WCSession defaultSession];
//        session.delegate = self;
//        [session activateSession];
//    }
//}

- (void)establishDB{
    //数据库路径
    
    NSString *doc1 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *doc2 = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:GROUP_ID] path];
    NSString *fileName1 = [doc1 stringByAppendingPathComponent:@"task.sqlite"];
    NSString *fileName2 = [doc2 stringByAppendingPathComponent:@"task.sqlite"];
    
    NSLog(@"DB PATH 1 : %@", doc1);
    NSLog(@"DB PATH 2 : %@", doc2);
    NSLog(@"FILE PATH 1 : %@", fileName1);
    NSLog(@"FILE PATH 2 : %@", fileName2);
    
    //原来如果有，先挪到第二个地方去（针对1.0版本）
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName1]){
        //复制到第二个
        if([[NSFileManager defaultManager] fileExistsAtPath:fileName2]){
            [[NSFileManager defaultManager] removeItemAtPath:fileName2 error:nil];
        }
        [[NSFileManager defaultManager] copyItemAtPath:fileName1 toPath:fileName2 error:nil];
        //删除第一个
        [[NSFileManager defaultManager] removeItemAtPath:fileName1 error:nil];
    }else{
        
    }
    
    //获得数据库
    self.db = [FMDatabase databaseWithPath:fileName2];
    //使用如下语句，如果打开失败，可能是权限不足或者资源不足。通常打开完操作操作后，需要调用 close 方法来关闭数据库。在和数据库交互之前，数据库必须是打开的。如果资源或权限不足无法打开或创建数据库，都会导致打开失败。
    if ([self.db open]){
        //创表
        
        //先看有没有这张表
        if(![self.db tableExists:@"t_task"]){
            BOOL result = [self.db executeUpdate:
                           @"CREATE TABLE IF NOT EXISTS t_task (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, appScheme text, reminderDays text, addDate date NOT NULL, reminderTime date, punchDateArr text, image blob, link text, endDate date, memo text)"];
            if (result){
                NSLog(@"创建表成功");
            }
            
        }else{
            //更新数据库表
            
            //图片选项    added on 1.0
            if (![self.db columnExists:@"image" inTableWithName:@"t_task"]){
                [self.db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ blob", @"t_task", @"image"]];
                NSLog(@"增加图片字段成功");
            }
            //链接选项    added on 1.0
            if (![self.db columnExists:@"link" inTableWithName:@"t_task"]){
                [self.db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text", @"t_task", @"link"]];
                NSLog(@"增加链接字段成功");
            }
            //结束日期选项    added on 1.0
            if (![self.db columnExists:@"endDate" inTableWithName:@"t_task"]){
                [self.db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ date", @"t_task", @"endDate"]];
                NSLog(@"增加结束日期字段成功");
            }
            //备注选项  added on 1.1
            if (![self.db columnExists:@"memo" inTableWithName:@"t_task"]){
                [self.db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text", @"t_task", @"memo"]];
                NSLog(@"增加备注字段成功");
            }
            //类别选项  added on 1.2
            if (![self.db columnExists:@"type" inTableWithName:@"t_task"]){
                [self.db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ integer", @"t_task", @"type"]];
                NSLog(@"增加类别字段成功");
            }
            //备注打卡数组选项  added on 1.4
            if (![self.db columnExists:@"punchMemoArr" inTableWithName:@"t_task"]){
                [self.db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text", @"t_task", @"punchMemoArr"]];
                NSLog(@"增加备注打卡数组字段成功");
            }
            //跳过打卡日期数组选项  added on 1.4
            if (![self.db columnExists:@"punchSkipArr" inTableWithName:@"t_task"]){
                [self.db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text", @"t_task", @"punchSkipArr"]];
                NSLog(@"增加打卡日期数组字段成功");
            }

        }
        
        //清理数据库缓存
        [self.db executeStatements:@"VACUUM t_task"];
    }
    
    NSLog(@"Current Path: %@", self.getDBPath);
    
}

- (FMDatabase *_Nonnull)getDB{
    return self.db;
}

- (void)closeDB{
    NSLog(@"db close");
    [self.db clearCachedStatements];
    [self.db close];
    self.db = NULL;
}

- (NSString *)getDBPath{
    NSString *doc2 = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:GROUP_ID] path];
    NSString *fileName2 = [doc2 stringByAppendingPathComponent:@"task.sqlite"];
    return fileName2;
}

- (long long)dbFilesize{
    NSFileManager* manager =[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:self.getDBPath]){
        return [[manager attributesOfItemAtPath:self.getDBPath error:nil] fileSize];
    }
    return 0;
}

//
//#pragma <WCSessionDelegate>
//
//- (void)sessionDidDeactivate:(WCSession *)session{
//    NSLog(@"sessionDidDeactivate");
//}
//
//- (void)sessionDidBecomeInactive:(WCSession *)session{
//    NSLog(@"sessionDidBecomeInactive");
//}
//
//- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary *)message replyHandler:(nonnull void (^)(NSDictionary * __nonnull))replyHandler {
//    NSString *counterValue = [message objectForKey:@"counterValue"];
//    
//    //Use this to update the UI instantaneously (otherwise, takes a little while)
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        NSLog(@"COUNTER %@", counterValue);
//        
//    });
//}

@end
