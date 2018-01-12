//
//  UIColor+Utils.h
//
//  Created by Eugenia Ye on 18/09/2017.
//

#import <UIKit/UIKit.h>


@interface UIColor (Utils)

+ (UIColor *)colorWithHex:(NSUInteger)rgbValue;

+ (UIColor *)mainSchemaColor;
+ (UIColor *)passcodeRingBgColor;
+ (UIColor *)passcodeRingLabelColor;
+ (UIColor *)passcodeNextFieldBgColor;

@end
