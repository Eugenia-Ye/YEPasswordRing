//
//  UIColor+Utils.m
//
//  Created by Eugenia Ye on 18/09/2017.
//
#import "UIColor+Utils.h"
#import "Constants.h"

@implementation UIColor (Utils)

+ (UIColor *)colorWithHex:(NSUInteger)rgbValue {
    return [UIColor colorWithRed:(CGFloat)(GetR(rgbValue)) / 255.f
                           green:(CGFloat)(GetG(rgbValue)) / 255.f
                            blue:(CGFloat)(GetB(rgbValue)) / 255.f
                           alpha:1.f];
}


+ (UIColor *)blueBackgroundColor {
    return [UIColor colorWithHex:0x0288D1];
}

+ (UIColor *)mainSchemaColor {
    return [UIColor blueBackgroundColor];
}

+ (UIColor *)passcodeRingBgColor {
    return [UIColor whiteColor];
}

+ (UIColor *)passcodeRingLabelColor {
    return [UIColor blueBackgroundColor];
}

+ (UIColor *)passcodeNextFieldBgColor {
    return [UIColor colorWithHex:kPasscodeNextFieldBgColorHex];
}

@end
