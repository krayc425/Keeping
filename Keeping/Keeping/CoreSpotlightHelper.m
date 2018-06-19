//
//  CoreSpotlightHelper.m
//  Keeping
//
//  Created by 宋 奎熹 on 2018/6/18.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

#import "CoreSpotlightHelper.h"
#import "TaskManager.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation CoreSpotlightHelper

static CoreSpotlightHelper* _instance = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [CoreSpotlightHelper shareInstance];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createCoreSpotlightIndexes) name:@"refresh_corespotlight" object:nil];
        [self createCoreSpotlightIndexes];
    }
    return self;
}

- (void)createCoreSpotlightIndexes{
    if(!CSSearchableIndex.isIndexingAvailable){
        NSLog(@"不支持");
        return;
    }
    
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithIdentifiers:@[@"tasks"] completionHandler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", error.localizedDescription);
        }else{
            NSLog(@"索引删除成功");
        }
    }];
    
    NSArray <Task *> *tasks = [[TaskManager shareInstance] getTasks];
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:tasks.count];
    for (Task *task in tasks) {
        CSSearchableItemAttributeSet *set = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeData];
        set.title = task.name;
        if(task.link != NULL && ![task.link isEqualToString:@""]){
            set.URL = [NSURL URLWithString:task.link];
        }
        if(task.image != NULL){
            set.thumbnailData = task.image;
        }
        if(task.memo != NULL && ![task.memo isEqualToString:@""]){
            set.contentDescription = task.memo;
        }
        set.keywords = @[task.name];
        set.startDate = task.addDate;
        if(task.endDate != NULL){
            set.endDate = task.endDate;
        }
        
        CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:[NSString stringWithFormat:@"%d", task.id] domainIdentifier:@"tasks" attributeSet:set];
        [items addObject:item];
    }
    
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:items completionHandler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", error.localizedDescription);
        }else{
            NSLog(@"索引添加成功");
        }
    }];
}

@end
