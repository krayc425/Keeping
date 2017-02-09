//
//  InterfaceController.m
//  KeepingWatch Extension
//
//  Created by 宋 奎熹 on 2017/2/8.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "InterfaceController.h"
#import "Task.h"
#import "DateTools.h"
#import "DateUtil.h"
#import <WatchConnectivity/WatchConnectivity.h>

#define GROUP_ID @"group.com.krayc.keeping"

@interface InterfaceController() <WCSessionDelegate>

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)testAction:(id)sender{
    NSString *counterString = [NSString stringWithFormat:@"%d", 10];
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[counterString] forKeys:@[@"counterValue"]];
    
    [[WCSession defaultSession] sendMessage:applicationData
                               replyHandler:^(NSDictionary *reply) {
                                   //handle reply from iPhone app here
                               }
                               errorHandler:^(NSError *error) {
                                   //catch any errors here
                               }
     ];
}

#pragma mark - Action

- (void)punchForTask{
    
    WCSession *session = [WCSession defaultSession];
    if ([session isReachable]) {
        
        NSDictionary *message = @{@"Operation":@"bounce"};
        
        
        [session sendMessage:message replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
            
            NSString *result = [replyMessage objectForKey:@"Reply"];
            
            NSLog(@"result is : %@", result);
            
        } errorHandler:^(NSError * _Nonnull error) {
            
            if (error) {
                NSLog(@"when send message : %@, error is : %@", message, error);
            }
            
        }];
        
        
    } else {
        
        NSLog(@"not reachable to iPhone");
        
    }
}

- (void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file{
    NSLog(@"FILE : %@",file.description);
}

@end



