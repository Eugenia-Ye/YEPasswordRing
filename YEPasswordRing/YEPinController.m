//
//  YEPinController.m
//
//  Created by Eugenia Ye on 18/09/2017.
//
#import <sys/utsname.h>
#import <AudioToolbox/AudioToolbox.h>

#import "YEPinController.h"
#import "MBProgressHUD.h"

#import "YERingView.h"
#import "UIColor+Utils.h"
#import "Constants.h"

@interface YEPinController () <YERingViewDelegate>
    
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *yAxisConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *yAxisToPinLabelConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *yAxisToIncorrectPinDetailConstraint;
    
@property (strong, nonatomic) IBOutlet UILabel *pinLabel;
@property (strong, nonatomic) IBOutlet UILabel *forgetPasscodeLabel;//"Enter your passcode to login\nForgot Passcode?"

@property (strong, nonatomic) IBOutlet UILabel *passcodePolicyLabel;//"Create your new passcode\nPasscode Policy"
    
@property (strong, nonatomic) IBOutlet UILabel *incorrectPinLabel;//Incorrect Passcode
@property (strong, nonatomic) IBOutlet UILabel *incorrectPinDetailLabel;//If you have forgotten your passcode, you will need to uninstall and reinstall the app.
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
    
@property (strong, nonatomic) IBOutlet YERingView *alphaRingView;
@property (strong, nonatomic) IBOutlet YERingView *numRingView;
    
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSTimer *maskPinDigitsTimer;
    
@property (strong, nonatomic) NSMutableData *pin;
@property (nonatomic) NSInteger pinOffset;
@property (nonatomic) NSInteger incorrectPinCount;
    
@property (nonatomic, strong) NSMutableArray *passcodeFields;
    
@end

@implementation YEPinController {
    //    SystemSoundID mBeep;
}


- (void)drawRings {
    self.alphaRingView.controller = self;
    self.numRingView.controller = self;
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
    
    [self.doneButton setBackgroundImage:[UIImage imageNamed:@"donePasscode"] forState:UIControlStateNormal];
    [self.doneButton setBackgroundImage:[UIImage imageNamed:@"donePasscode_disable"] forState:UIControlStateDisabled];
    
    
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"deletePasscode"] forState:UIControlStateNormal];
    
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"deletePasscode_disable"] forState:UIControlStateDisabled];
    
    
    //    CFURLRef alertSoundUrlRef = CFBridgingRetain([[NSBundle mainBundle] URLForResource:@"alert"
    //                                                                         withExtension:@"caf"]);
    //    AudioServicesCreateSystemSoundID(alertSoundUrlRef, &mBeep);
    //    CFRelease(alertSoundUrlRef);
}
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self reset];
    self.incorrectPinCount = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    self.passcodeFields = [[NSMutableArray alloc] initWithCapacity:PASSCODE_LENGTH_MAX];
    
    for (int i = 0; i < PASSCODE_LENGTH_MAX; i++) {
        
        float startingX;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        //Regardless of how many characters are set in the passcode, we still start by showing four empty squares.
        startingX = screenWidth/2 - kPasscodeFieldInsets/2 - (PASSCODE_LENGTH_MIN/2 - 1) * kPasscodeFieldInsets - PASSCODE_LENGTH_MIN/2 * kPasscodeFieldHeight;
        
        CGFloat fieldY = self.alphaRingView.frame.origin.y - 60.0f;
        
        UITextField *field  = [[UITextField alloc] initWithFrame:CGRectMake(startingX + (kPasscodeFieldHeight + kPasscodeFieldInsets) * i, fieldY, kPasscodeFieldHeight, kPasscodeFieldHeight)];
        
        field.backgroundColor = [UIColor whiteColor];
        field.textColor = [UIColor blackColor];
        field.font = [UIFont fontWithName:@"Helvetica-Bold" size:[UIFont systemFontSize]];
        field.textAlignment = NSTextAlignmentCenter;
        field.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        field.userInteractionEnabled = NO;
        
        //Regardless of how many characters are set in the passcode, we still start by showing four empty squares.
        if (i >= PASSCODE_LENGTH_MIN) {
            field.hidden = YES;
        }
        
        [self.view addSubview:field];
        
        [self.passcodeFields addObject:field];
    }
    
    
    
    NSString *createStr = @"Create your new passcode";
    NSString *policyDefStr = @"Passcode Policy";
    
    NSString *str = [NSString stringWithFormat:@"%@\n%@", createStr, policyDefStr];
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:str attributes:nil];
    
    NSRange linkCreateR = NSMakeRange(0, createStr.length);
    NSDictionary *linkCreateAttrs = @{ NSForegroundColorAttributeName : [UIColor blackColor]};
    
    NSRange linkPolicyR = NSMakeRange(createStr.length, policyDefStr.length + 1);
    NSDictionary *linkPolicyAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [attributedStr setAttributes:linkCreateAttrs range:linkCreateR];
    [attributedStr addAttributes:linkPolicyAttributes range:linkPolicyR];
    
    // Assign attributedText to UILabel
    self.passcodePolicyLabel.attributedText = attributedStr;
    
    self.passcodePolicyLabel.numberOfLines = 0;
    
    self.passcodePolicyLabel.userInteractionEnabled = YES;
    [self.passcodePolicyLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPasscodePolicyLabel)]];
    
    self.passcodePolicyLabel.hidden = NO;
    self.forgetPasscodeLabel.hidden = YES;
}
    
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    //    AudioServicesDisposeSystemSoundID(mBeep);
}
    
    
- (void)applicationDidEnterBackground {
    if (self.hud.alpha > 0.f) {
        [self.hud hide:YES];
    }
    self.incorrectPinCount = 0;
}
    
- (NSUInteger)supportedInterfaceOrientations
    {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            //iPhone
            return UIInterfaceOrientationMaskPortrait;
        }
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
    

- (void)reset {
    [self drawRings];
    
    for (int i = 0; i < PASSCODE_LENGTH_MAX; i++) {
        UITextField *field = self.passcodeFields[i];
        //Regardless of how many characters are set in the passcode, we still start by showing four empty squares.
        if (i >= PASSCODE_LENGTH_MIN)
        field.hidden = YES;
        else
        field.hidden = NO;
    }
    
    //initialize NSMutableData
    self.pin =  [[NSMutableData alloc] initWithCapacity:PASSCODE_LENGTH_MAX];
    
    self.pinOffset = 0;
    
    //clear NSMutableData
    [self.pin resetBytesInRange:NSMakeRange(0, PASSCODE_LENGTH_MAX)];
    
    self.pinLabel.text = @"";
    
    for (int i = 0; i < PASSCODE_LENGTH_MAX; i++) {
        UITextField *field = (UITextField *)self.passcodeFields[i];
        field.text = @"";
    }
    
    self.doneButton.enabled = NO;
    self.deleteButton.enabled = NO;
    
    if (self.incorrectPinCount > 0) {
        //beep when enter wrong passcode
        //AudioServicesPlayAlertSound(mBeep);
        //iPhone vibrate when enter wrong passcode
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        self.incorrectPinLabel.hidden = NO;////Incorrect Passcode
        self.incorrectPinDetailLabel.hidden = NO;//If you have forgotten your passcode, you will need to uninstall and reinstall the app.
        self.forgetPasscodeLabel.hidden = YES;
        self.passcodePolicyLabel.hidden = YES;
    } else {
        self.incorrectPinLabel.hidden = YES;
        self.incorrectPinDetailLabel.hidden = YES;
    }
    
    [self relocatePasscodeFields];
}
    
- (void)done {
    
    BOOL success = YES;
    
    
    //success = [_applicationState checkUserPin:((int *)self.pin.bytes) passcodeLen:(int)self.pinOffset];
    
    if (success) {
        [self showPin:((int *)self.pin.bytes) passcodeLen:(int)self.pinOffset duration:3];
        
        
        
    } else {
        
        if (self.incorrectPinCount++ > 2) {
            float delay = powf(2, self.incorrectPinCount - 3);
            
            self.hud.labelText = @"Incorrect PIN";
            self.hud.taskInProgress = YES;
            self.hud.progress = 1 / delay;
            [self.hud show:YES];
            
            NSDate *fireDate = [NSDate dateWithTimeInterval:1.f sinceDate:[NSDate date]];
            NSTimer *timer = [[NSTimer alloc] initWithFireDate:fireDate
                                                      interval:1.0
                                                        target:self
                                                      selector:@selector(updateHudProgress:)
                                                      userInfo:[NSNumber numberWithFloat:delay]
                                                       repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        }
        
        [self reset];
        
        for (int i = 0; i < PASSCODE_LENGTH_MAX; i++) {
            UITextField *field = self.passcodeFields[i];
            field.hidden = YES;
            
            //relocate all passcode fields
            [self relocatePasscodeFields];
        }
        
    }
}
    
#pragma mark
-(void)showPin:(int [])pin passcodeLen:(int)len duration:(NSTimeInterval)time {
        
        NSString *passcode = @"";
        
        for (int i = 0; i < len; i++) {
            // ASCII to NSString
            passcode = [passcode stringByAppendingFormat:@"%c", pin[i]];
        }
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        UIView *showview =  [[UIView alloc]init];
        showview.backgroundColor = [UIColor grayColor];
        showview.frame = CGRectMake(1, 1, 1, 1);
        showview.alpha = 1.0f;
        showview.layer.cornerRadius = 5.0f;
        showview.layer.masksToBounds = YES;
        [window addSubview:showview];
        
        UILabel *label = [[UILabel alloc]init];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.f],
                                     NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        CGSize labelSize = [passcode boundingRectWithSize:CGSizeMake(207, 999)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes context:nil].size;
        
        label.frame = CGRectMake(10, 5, labelSize.width +20, labelSize.height);
        label.text = passcode;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = 1;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:15];
        [showview addSubview:label];
        
        showview.frame = CGRectMake((screenSize.width - labelSize.width - 20)/2,
                                    screenSize.height - 300,
                                    labelSize.width+40,
                                    labelSize.height+10);
        [UIView animateWithDuration:time animations:^{
            showview.alpha = 0;
        } completion:^(BOOL finished) {
            [showview removeFromSuperview];
        }];
    }
    
- (void)updateHudProgress:(NSTimer *)timer {
    if (self.hud.alpha <= 0.f) {
        // HUD has been hidden because application entered background, so stop the timer
        [timer invalidate];
        self.hud.taskInProgress = NO;
        return;
    }
    
    NSNumber *totalDelay = (NSNumber *)timer.userInfo;
    self.hud.progress += 1 / totalDelay.floatValue;
    if (self.hud.progress >= 1.0) {
        [timer invalidate];
        [self.hud hide:YES];
        self.hud.taskInProgress = NO;
    }
}
    
- (void)tapOnForgetPasscodeLabel {
    NSString *msgDetail = @"Forgot Passcode";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Passcode?"
                                                    message:msgDetail
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    
    [alert show];
    
}
    
- (void)tapOnPasscodePolicyLabel {

    NSString *msgDetail = @"Passcode policy is:";
    msgDetail = [msgDetail stringByAppendingString:@"\n"];
    msgDetail = [msgDetail stringByAppendingString:@"Your passcode must be 4 - 8 characters long and contain characters a-z, A-Z, 0-9 and common punctuation."];//localization
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passcode Policy"
                                                    message:msgDetail
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    
    [alert show];
}
    
- (IBAction)doneClicked {
    
    [self maskAllPinDigits];
    
    [self done];
    
}
    
- (IBAction)deleteClicked {
    [self maskAllPinDigits];
    
    if (self.pinOffset > 0) {
        NSRange range;
        range.location = self.pinLabel.text.length - 1;
        range.length = 1;
        self.pinLabel.text = [self.pinLabel.text stringByReplacingCharactersInRange:range withString:@""];
        
        //Usually use NSInteger when you don't know what kind of processor architecture your code might run on
        //int type, which on 32 bit systems is just an int, while on a 64-bit system it's a long
        [self.pin setLength:(self.pinOffset-1) * sizeof(NSInteger)];
        
        
        self.pinOffset--;
        
        UITextField *field = self.passcodeFields[self.pinOffset];
        field.text = @"";
        if (self.pinOffset >= PASSCODE_LENGTH_MIN) {
            field.hidden = YES;
            
            //hide next grey field
            if (self.pinOffset < PASSCODE_LENGTH_MAX-1) {
                UITextField *nextField = self.passcodeFields[self.pinOffset+1];
                nextField.hidden = YES;
            }
            
            
            //add a new grey field
            if (self.pinOffset <= PASSCODE_LENGTH_MAX-1) {
                UITextField *newNextField = self.passcodeFields[self.pinOffset];
                newNextField.hidden = NO;
                newNextField.backgroundColor = [UIColor passcodeNextFieldBgColor];
            }
            
            
            //relocate all passcode fields when passcode fields have been removed
            [self relocatePasscodeFields];
        } else if (self.pinOffset == PASSCODE_LENGTH_MIN-1) {
            //hide the PASSCODE_LENGTH_MIN+1 grey field
            UITextField *nextField = self.passcodeFields[PASSCODE_LENGTH_MIN];
            nextField.hidden = YES;
        }
    }
    
    if (self.pinOffset < PASSCODE_LENGTH_MIN) {
        self.doneButton.enabled = NO;
    }
    
    [self hideOrShowDeleteButton];
}
    
- (void)maskAllPinDigits {
    [self.maskPinDigitsTimer invalidate];
    
    NSString *masked = @"";
    for (int i=0; i < self.pinLabel.text.length; i++) {
        masked = [masked stringByAppendingString:@"*"];
        
        UITextField *field = self.passcodeFields[i];
        field.text = @"*";
    }
    self.pinLabel.text = masked;
}
    
- (void)hideOrShowDeleteButton {
    //allow to enable user interaction of 'delete' button both when seeting new pin or enter existing pin
    self.deleteButton.enabled = (self.pinOffset > 0);
}
    
    
#pragma mark - YERingViewDelegate
- (void)ringButtonClicked:(int)asciiCode {
    
    //hide incorrectPinLabel and incorrectPinDetailLabel when ring button clicked
    self.incorrectPinLabel.hidden = YES;
    self.incorrectPinDetailLabel.hidden = YES;
    
    
    if (self.pinOffset <= PASSCODE_LENGTH_MIN) {
        for (int i = 0; i < PASSCODE_LENGTH_MIN; i++) {
            UITextField *field = self.passcodeFields[i];
            field.hidden = NO;
        }
    }
    
    NSInteger digit = asciiCode;
    
    if (self.pinOffset >= PASSCODE_LENGTH_MAX) {
        // number buttons are unresponsive if we've already collected enough digits
        return;
    }
    
    //move NSMutableData index to 0
    if (self.pinOffset == 0) {
        [self.pin setLength:0];
    }
    
    //fill NSMutableData
    int digitI = (int)digit;
    NSData *payload = [NSData dataWithBytes:&digitI length:sizeof(digitI)];
    [self.pin appendData:payload];
    
    //The actual character should be shown for a maximum of one second or until the user presses another key
    if (self.pinOffset > 0) {
        UITextField *preField = self.passcodeFields[self.pinOffset - 1];
        preField.hidden = NO;
        preField.text = @"*";
    }
    
    self.pinOffset++;
    
    
    self.pinLabel.text = [self.pinLabel.text stringByAppendingFormat:@"%c", (int)digit];
    
    UITextField *field = self.passcodeFields[self.pinOffset - 1];
    
    if ((self.pinOffset >= PASSCODE_LENGTH_MIN) && (self.pinOffset <= PASSCODE_LENGTH_MAX-1)) {
        UITextField *nextField = self.passcodeFields[self.pinOffset];
        
        nextField.hidden = NO;
        nextField.backgroundColor = [UIColor passcodeNextFieldBgColor];
    }
    
    field.backgroundColor = [UIColor whiteColor];
    field.textColor = [UIColor blackColor];
    field.hidden = NO;
    field.text = [NSString stringWithFormat:@"%c", (int)digit];
    
    self.maskPinDigitsTimer = [NSTimer timerWithTimeInterval:kPinControllerDelayBeforeMaskingPinDigit target:self selector:@selector(maskAllPinDigits) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.maskPinDigitsTimer forMode:NSDefaultRunLoopMode];
    
    
    //relocate all passcode fields when more passcode fields have been added
    if ((self.pinOffset >= PASSCODE_LENGTH_MIN) && (self.pinOffset <= PASSCODE_LENGTH_MAX))
    [self relocatePasscodeFields];
    
    //coz we don't want to give a clue as to the length of the passcode but four characters is the minimum
    //not automatically call [self done] if user has enter exact NUMBER of passcode characters
    //enable done button if minimum characters(four) has been entered
    //
    if ((PASSCODE_LENGTH_MIN <= self.pinOffset) && ( self.pinOffset < PASSCODE_LENGTH_MAX)) {
        self.doneButton.enabled = YES;
    } else if (self.pinOffset == PASSCODE_LENGTH_MAX) {
        /*
         * when not setting a new PIN, they're done when PASSCODE_LENGTH_MAX passcode characters has entered
         */
        //[self done];
    }
    
    [self hideOrShowDeleteButton];
}
    
- (void)relocatePasscodeFields {
    
    //before relocatePasscodeFields, hide all passcode fields first
    for (int i = 0; i < PASSCODE_LENGTH_MAX; i++) {
        UITextField *field = self.passcodeFields[i];
        field.hidden = YES;
        [field removeFromSuperview];
    }
    
    for(UIView *subview in [self.view subviews]) {
        if([subview isKindOfClass:[UITextField class]]) {
            [subview removeFromSuperview];
        } else {
            // Do nothing - not a UITextField instance
        }
    }
    
    float startingX;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    int passcodeCurLen = PASSCODE_LENGTH_MIN;
    if ((int)self.pinOffset != 0) {
        passcodeCurLen = (int)self.pinOffset;
    }
    
    if (passcodeCurLen % 2 == 0) {
        startingX = screenWidth/2 - kPasscodeFieldInsets/2 - (passcodeCurLen/2 - 1) * kPasscodeFieldInsets - passcodeCurLen/2 * kPasscodeFieldHeight;
    } else {
        startingX = screenWidth/2 - kPasscodeFieldHeight/2 - passcodeCurLen/2 * kPasscodeFieldInsets - passcodeCurLen/2 * kPasscodeFieldHeight;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    for (int i = 0; i < PASSCODE_LENGTH_MAX; i++) {
        UITextField *textField = self.passcodeFields[i];
        
        if ((i < PASSCODE_LENGTH_MIN) || (i < (int)self.pinOffset))
        textField.hidden = NO;
        
        CGRect textFieldFrame = textField.frame;
        textFieldFrame.origin.x = startingX + (kPasscodeFieldHeight + kPasscodeFieldInsets) * i;
        textField.frame = textFieldFrame;
        
        [self.view addSubview:textField];
    }
    
    [UIView commitAnimations];
}
    
@end
