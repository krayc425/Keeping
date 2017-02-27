//
//  UIImage+Extensions.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/27.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

CGFloat DegreesToRadians(CGFloat degrees);

CGFloat RadiansToDegrees(CGFloat radians);

@interface UIImage (Extensions)

- (UIImage *)imageAtRect:(CGRect)rect;- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;

- (UIImage *)imageByScalingToSize:(CGSize)targetSize;

- (UIImage *)imageRotatedByRadians:(CGFloat)radians;

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;

- (UIImage *) imageWithBackgroundColor:(UIColor *)bgColor
                           shadeAlpha1:(CGFloat)alpha1
                           shadeAlpha2:(CGFloat)alpha2
                           shadeAlpha3:(CGFloat)alpha3
                           shadowColor:(UIColor *)shadowColor
                          shadowOffset:(CGSize)shadowOffset
                            shadowBlur:(CGFloat)shadowBlur;

- (UIImage *)imageWithShadowColor:(UIColor *)shadowColor
                     shadowOffset:(CGSize)shadowOffset
                       shadowBlur:(CGFloat)shadowBlur;

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;

- (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
                customAlbumName:(NSString *)customAlbumName
                completionBlock:(void (^)(void))completionBlock
                   failureBlock:(void (^)(NSError *error))failureBlock;
@end;
