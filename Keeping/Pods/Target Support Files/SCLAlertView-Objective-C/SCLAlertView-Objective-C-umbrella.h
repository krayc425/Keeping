#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SCLAlertView.h"
#import "SCLAlertViewResponder.h"
#import "SCLAlertViewStyleKit.h"
#import "SCLButton.h"
#import "SCLMacros.h"
#import "SCLSwitchView.h"
#import "SCLTextView.h"
#import "SCLTimerDisplay.h"
#import "UIImage+ImageEffects.h"

FOUNDATION_EXPORT double SCLAlertView_Objective_CVersionNumber;
FOUNDATION_EXPORT const unsigned char SCLAlertView_Objective_CVersionString[];

