//
//  CoreSpotlightHelper.h
//  Keeping
//
//  Created by 宋 奎熹 on 2018/6/18.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoreSpotlightHelper : NSObject

+ (_Nonnull instancetype)shareInstance;

- (void)createCoreSpotlightIndexes;

@end

NS_ASSUME_NONNULL_END
