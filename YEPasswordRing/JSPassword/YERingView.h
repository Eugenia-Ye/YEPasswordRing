//
//  YERingView.h
//
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE


@class YERingView;

@protocol YERingViewDelegate <NSObject>

- (void)ringButtonClicked:(int)asciiCode;

@end


@interface YERingView : UIView

@property (nonatomic) IBInspectable CGFloat thickness;
@property (nonatomic) IBInspectable int segments;

@property (weak, nonatomic) IBOutlet UIViewController<YERingViewDelegate> *controller;

@end
