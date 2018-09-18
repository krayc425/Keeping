//
//  IntentHandler.m
//  KeepingIntentExtension
//
//  Created by 宋 奎熹 on 2018/9/19.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

#import "IntentHandler.h"

@interface IntentHandler ()

@end

@implementation IntentHandler

- (id)handlerForIntent:(INIntent *)intent {
    // This is the default implementation.  If you want different objects to handle different intents,
    // you can override this and return the handler you want for that particular intent.
    
    if ([[intent class] isKindOfClass:INSetTaskAttributeIntent.self]) {
        
    }
    
    return self;
}

@end
