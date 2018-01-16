//
//  YERingView.m
//
//

#import "YERingView.h"
//#import "CMPopTipView.h"
#import "UIColor+Utils.h"
#import "Constants.h"

@interface YERingView ()

@property (nonatomic) CGFloat ringButtonAlpha;
@property (strong, nonatomic) NSTimer *digitHintTimer;
///@property (nonatomic, strong) CMPopTipView *popTipView;

@end

@implementation YERingView

// having initwithcoder allows us to use YERingView in a Nib.
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initDefaults];
    }

    [self createAlphaNumericLabel];

    return self;
}

-(void)initDefaults {
    self.thickness = 12.0f;
    self.segments = 26;
    self.ringButtonAlpha = ringButtonAlphaDefault;
}

-(void)createAlphaNumericLabel {
    if (self.tag == ringButtonForAlphabetTag) {
        self.segments = 26;
    } else if (self.tag == ringButtonForNumberTag) {
        self.segments = 10;
    } else {
        self.segments = 2;
    }

    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float swidth = self.bounds.size.width;
    
    if (self.segments == 26){
        swidth = screenWidth;
    } else if (self.segments == 10){
        swidth = screenWidth * numberRingWidthRatio;
    }

    CGFloat width = swidth * labelRadiusRatio;
    CGFloat radius = (width - self.thickness * 2.5f) / 2.0f;
    CGPoint centerPoint = CGPointMake(swidth/2.0f, swidth/2.0f);
    CGFloat interval = M_PI * 2 / self.segments;
    CGFloat thicknessMultiplierWidth = 3.0f;
    CGFloat thicknessMultiplierHeight = 3.0f;
    CGSize size = CGSizeMake(self.thickness * thicknessMultiplierWidth, self.thickness * thicknessMultiplierHeight);

    int asciiCode = 0;
    if (self.segments == 26) {
        asciiCode = 65;
    } else if (self.segments == 10) {
        asciiCode = 48;
    }

    if (self.segments == 2) {
        //TODO
    } else {
        for (int i = 0; i < self.segments; i++) {
            CGFloat theta = interval * (i + 0.5f);
            CGPoint topLeft = CGPointMake(sin(theta) * radius + centerPoint.x - size.width / 2.0f, centerPoint.y - cos(theta) * radius - size.height / 2.0f);
            NSString *label = [NSString stringWithFormat:@"%c", asciiCode + i];

            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:label forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
            [button setTitleColor:[UIColor passcodeRingLabelColor] forState:UIControlStateNormal];
            button.frame = CGRectMake(topLeft.x, topLeft.y, size.width, size.height);
            [self addSubview:button];
        }
    }
}

-(void)buttonPressed:(UIButton *)whichButton {
    [self.controller ringButtonClicked:[whichButton.titleLabel.text characterAtIndex:0]];


//    self.popTipView = [[CMPopTipView alloc] initWithMessage:whichButton.titleLabel.text];
//
//    ///self.popTipView.backgroundColor = [UIColor whiteColor];
//    self.popTipView.backgroundColor = [UIColor blackColor];
//    ///self.popTipView.textColor = [UIColor mainSchemaColor];
//    self.popTipView.textColor = [UIColor whiteColor];
//
//    self.popTipView.dismissAlongWithUserInteraction = YES;
//    self.popTipView.has3DStyle = NO;
//    self.popTipView.dismissTapAnywhere = YES;
//    [self.popTipView autoDismissAnimated:YES atTimeInterval:0.1];//0.2
//
//    [self.popTipView presentPointingAtView:whichButton inView:self animated:YES];

}

-(void)drawRect:(CGRect)rect {
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float swidth = self.bounds.size.width;
 
    if (self.tag == ringButtonForAlphabetTag) {
        swidth = screenWidth;
    } else if (self.tag == ringButtonForNumberTag) {
        swidth = screenWidth * numberRingWidthRatio;
    }
   
    CGFloat width = swidth * labelRadiusRatio;
    CGFloat radius = (width - self.thickness) / 2.0f;
    CGPoint centerPoint = CGPointMake(swidth / 2.0f, swidth / 2.0f);

    struct CGColor *backgroundColor = [UIColor passcodeRingBgColor].CGColor;

    // draw ring
    CGMutablePathRef arc = CGPathCreateMutable();

    CGPathAddArc(arc, NULL, centerPoint.x, centerPoint.y, radius, 0, 2 * M_PI, YES);

    CGPathRef strokedArc = CGPathCreateCopyByStrokingPath(arc, NULL, self.thickness, kCGLineCapButt, kCGLineJoinMiter, 10);

    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextAddPath(c, strokedArc);

    CGContextSetFillColorWithColor(c, backgroundColor);
    if (self.segments == 2)
        CGContextSetFillColorWithColor(c, [UIColor whiteColor].CGColor);
    else
        CGContextSetFillColorWithColor(c, backgroundColor);


    CGContextDrawPath(c, kCGPathFill);

    // draw lines
    CGFloat interval = M_PI * 2 / self.segments;
    CGFloat outsideRadius = radius + (self.thickness / 2.0f);
    CGFloat insideRadius = radius - (self.thickness / 2.0f);

    if (self.segments == 2) {
        CGPoint leftPoint = CGPointMake(centerPoint.x - self.thickness + 2.0f, centerPoint.y);
        CGPoint rightPoint = CGPointMake(centerPoint.x + self.thickness - 2.0f, centerPoint.y);

        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:leftPoint];
        [path addLineToPoint:rightPoint];
        path.lineWidth = 1;
        [[UIColor lightGrayColor] setStroke];
        [path stroke];

    } else {
        for (int i = 0; i < self.segments; i++) {
            CGFloat theta = interval * i;
            CGPoint outside = CGPointMake(sin(theta) * outsideRadius + centerPoint.x, centerPoint.y - cos(theta) * outsideRadius);
            CGPoint inside = CGPointMake(sin(theta) * insideRadius + centerPoint.x, centerPoint.y - cos(theta) * insideRadius);

            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:outside];
            [path addLineToPoint:inside];
            path.lineWidth = 1;
            [[UIColor lightGrayColor] setStroke];
            [path stroke];
        }
    }
}

@end
