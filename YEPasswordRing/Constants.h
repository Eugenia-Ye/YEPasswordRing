//
//  Constans.h
//
//  Created by Eugenia Ye on 18/09/2017.
//

#ifndef YE_Constans_h
#define YE_Constans_h

// YEPinController
#define PASSCODE_LENGTH_MIN         4
#define PASSCODE_LENGTH_MAX         8
#define kPinControllerDelayBeforeMaskingPinDigit  1
#define kPasscodeFieldHeight 30 //password field's height/width
#define kPasscodeFieldInsets 5 //password field's space
#define kPasscodeNextFieldBgColorHex        0x4C96BD
#define ringButtonAlphaDefault                    0.5
#define ringButtonForAlphabetTag                  1401
#define ringButtonForNumberTag                    1402
#define labelRadiusRatio                          0.95f
#define numberRingWidthRatio                      0.725f


// UIColor+Utils
#define GetR(rgb) ((unsigned char)((unsigned int)rgb >> 16))
#define GetG(rgb) ((unsigned char)((unsigned int)rgb >> 8))
#define GetB(rgb) ((unsigned char)((unsigned int)rgb))


#endif
