//
//  iSnackBar.m
//  iSnackBar
//
//  Created by Mahdi Boukhris on 12/12/2017.
//  Copyright © 2017 MB Apps. All rights reserved.
//

#import "iSnackBar.h"
#import <sys/utsname.h>

static iSnackBar *currentlyVisibleSnackbar					=	nil;
static NSTimer* dismissalTimer								=	nil;
static id selectionDelegate									=	nil;

@implementation iSnackBar

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
	}
	return self;
}

+ (void) snackBarWithMessage:(NSString*) message {
	[iSnackBar snackBarWithMessage:message font:nil backgroundColor:nil textColor:nil duration:0];
}

+ (void) snackBarWithMessage:(NSString*) message
						font:(UIFont*) font
			 backgroundColor:(UIColor*) bgColor
				   textColor:(UIColor*) textColor
					duration:(float) duration {
	UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
	while (topController.presentedViewController) {
		topController = topController.presentedViewController;
	}
	
	UIView *parentView = topController.view;
	
	if(currentlyVisibleSnackbar) {
		[currentlyVisibleSnackbar removeFromSuperview];
		currentlyVisibleSnackbar			=	nil;
		[dismissalTimer invalidate];
	}

	currentlyVisibleSnackbar				=	[[iSnackBar alloc] initWithFrame:CGRectZero];
	currentlyVisibleSnackbar.translatesAutoresizingMaskIntoConstraints = NO;

	UILabel* mMessageLabel			=	[[UILabel alloc] init];
	[mMessageLabel setNumberOfLines:0];
	[mMessageLabel setText:message];
	
	if(!bgColor) {
		bgColor				=	[UIColor blackColor];
	}
	
	if(!textColor) {
		textColor			=	[UIColor whiteColor];
	}
	
	if(!font) {
		font				=	[UIFont systemFontOfSize:13.f];
	}
	
	[currentlyVisibleSnackbar setBackgroundColor:bgColor];
	[mMessageLabel setTextColor:textColor];
	[mMessageLabel setFont:font];
	
	[currentlyVisibleSnackbar addSubview:mMessageLabel];
	[parentView addSubview:currentlyVisibleSnackbar];
	
	[currentlyVisibleSnackbar setFrame:CGRectMake(0, parentView.frame.size.height, parentView.frame.size.width, 60)];
	[mMessageLabel setFrame:CGRectMake(8, 8, parentView.frame.size.width - 16, 0)];
	[mMessageLabel sizeToFit];
	[currentlyVisibleSnackbar setFrame:CGRectMake(0, parentView.frame.size.height, parentView.frame.size.width, CGRectGetMaxY(mMessageLabel.frame) + 8)];
	
	[UIView animateWithDuration:0.3 animations:^{
		long snackBarYPosition			=	parentView.frame.size.height - currentlyVisibleSnackbar.frame.size.height;
		[currentlyVisibleSnackbar setFrame:CGRectMake(0, snackBarYPosition, parentView.frame.size.width, CGRectGetMaxY(mMessageLabel.frame) + 8)];
	}];
	
	if(duration == 0) {
		duration = 2; // Default duration
	}
	
	dismissalTimer = [NSTimer scheduledTimerWithTimeInterval:duration
													  target:self
													selector:@selector(dismissSnackBar)
													userInfo:nil
													 repeats:NO];
}

+ (void) snackBarWithMessage:(NSString*) message action:(NSString*) actionName delegate:(id) delegate {
//    [iSnackBar snackBarWithMessage:message font:nil backgroundColor:nil textColor:nil action:actionName delegate:delegate duration:0];
}

+ (void) snackBarWithMessage:(NSString*)message
                        font:(UIFont*)font
             backgroundColor:(UIColor*)bgColor
                   textColor:(UIColor*)textColor
                 actionTitle:(NSString*)actionTitle
            actionTitleColor:(UIColor *)actionTitleColor
                    delegate:(id)delegate
                    duration:(float)duration {
	UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
	while (topController.presentedViewController) {
		topController = topController.presentedViewController;
	}
	
	UIView *parentView = topController.view;
	
	if(currentlyVisibleSnackbar) {
		[currentlyVisibleSnackbar removeFromSuperview];
		currentlyVisibleSnackbar			=	nil;
		[dismissalTimer invalidate];
	}
	
	selectionDelegate					=	delegate;
	currentlyVisibleSnackbar				=	[[iSnackBar alloc] initWithFrame:CGRectZero];
	currentlyVisibleSnackbar.translatesAutoresizingMaskIntoConstraints = NO;
	
	UILabel* mMessageLabel				=	[[UILabel alloc] init];
	[mMessageLabel setNumberOfLines:0];
	[mMessageLabel setText:message];
	
	UIButton* mActionButton				=	[[UIButton alloc] init];
	[mActionButton setTitle:actionTitle forState:UIControlStateNormal];
    if (actionTitleColor) {
        [mActionButton setTitleColor:actionTitleColor forState:UIControlStateNormal];
    }
	[mActionButton addTarget:self action:@selector(didSelectSnackBarActionButton:) forControlEvents:UIControlEventTouchUpInside];
	
	if(!bgColor) {
		bgColor				=	[UIColor blackColor];
	}
	
	if(!textColor) {
		textColor			=	[UIColor whiteColor];
	}
	
	if(!font) {
		font				=	[UIFont systemFontOfSize:13.f];
	}
	
	[currentlyVisibleSnackbar setBackgroundColor:bgColor];
	[mMessageLabel setTextColor:textColor];
	[mMessageLabel setFont:font];
    [mMessageLabel setTextAlignment:NSTextAlignmentRight];
	[mActionButton.titleLabel setFont:font];
    
    
	[mActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[mActionButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
	[mActionButton sizeToFit];
	
	[currentlyVisibleSnackbar addSubview:mMessageLabel];
	[currentlyVisibleSnackbar addSubview:mActionButton];
	[parentView addSubview:currentlyVisibleSnackbar];
	
	long buttonWidth = mActionButton.frame.size.width + 16;
	[mActionButton setFrame:CGRectMake(parentView.frame.size.width - buttonWidth - 8, 0, buttonWidth, mActionButton.frame.size.height)];
    
    CGFloat additionalHeight = 0;
    // ,, , , , , , , , , , , ,
    if ([[iSnackBar deviceName] isEqualToString:@"iPhone 4"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone 4s"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone 5"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone 5c"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone 5s"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone 6"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone 6 Plus"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone 6s"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone 6s Plus"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone 7"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone 7 Plus"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone SE"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone 8"] ||
        [[iSnackBar deviceName] isEqualToString:@"iPhone 8 Plus"]) {
        
    } else {
        additionalHeight = 20;
    }
	
	[currentlyVisibleSnackbar setFrame:CGRectMake(0, -(80+additionalHeight), parentView.frame.size.width, 80+additionalHeight)];
	[mMessageLabel setFrame:CGRectMake(8, 28+additionalHeight, currentlyVisibleSnackbar.frame.size.width - 16, 0)];
	[mMessageLabel sizeToFit];
    [mMessageLabel setFrame:CGRectMake(currentlyVisibleSnackbar.frame.size.width - mMessageLabel.frame.size.width - 8, mMessageLabel.frame.origin.y, mMessageLabel.frame.size.width, mMessageLabel.frame.size.height)];
	[currentlyVisibleSnackbar setFrame:CGRectMake(0, -80, parentView.frame.size.width, CGRectGetMaxY(mMessageLabel.frame) + 28+additionalHeight)];
	
	long actionButtonYPosition			=	(currentlyVisibleSnackbar.frame.size.height / 2) - (mActionButton.frame.size.height / 2);
	[mActionButton setFrame:CGRectMake(mActionButton.frame.origin.x, actionButtonYPosition, buttonWidth, mActionButton.frame.size.height)];

	[UIView animateWithDuration:0.3 animations:^{
		[currentlyVisibleSnackbar setFrame:CGRectMake(0, 0, parentView.frame.size.width, CGRectGetMaxY(mMessageLabel.frame) + 8)];
	}];
    
    int finalDuration = 2;
    
    switch ((int) duration) {
        case 0:
        finalDuration = 2.75;
        break;
        
        case -1:
        finalDuration = 1.5;
        break;
        
        case -2:
        finalDuration = 1000000;
        break;
        
        default:
        break;
    }
	
	dismissalTimer = [NSTimer scheduledTimerWithTimeInterval:finalDuration
													  target:self
													selector:@selector(dismissSnackBar)
													userInfo:nil
													 repeats:NO];
}

+ (void) dismissSnackBar {
	UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
	while (topController.presentedViewController) {
		topController = topController.presentedViewController;
	}
		
	[UIView animateWithDuration:0.2 animations:^{
		long snackBarYPosition			=	-currentlyVisibleSnackbar.frame.size.height;
		[currentlyVisibleSnackbar setFrame:CGRectMake(0, snackBarYPosition, currentlyVisibleSnackbar.frame.size.width, currentlyVisibleSnackbar.frame.size.height)];
	} completion:^(BOOL finished) {
		[currentlyVisibleSnackbar removeFromSuperview];
		currentlyVisibleSnackbar			=	nil;
	}];
}

+ (void) didSelectSnackBarActionButton:(UIButton*) sender {
	[iSnackBar dismissSnackBar];
	
	if(selectionDelegate && [selectionDelegate respondsToSelector:@selector(didSelectSnackBarAction)]) {
		[selectionDelegate didSelectSnackBarAction];
	}
}

+ (NSString *)deviceName
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      : @"Simulator",
                              @"x86_64"    : @"Simulator",
                              @"iPod1,1"   : @"iPod Touch",        // (Original)
                              @"iPod2,1"   : @"iPod Touch",        // (Second Generation)
                              @"iPod3,1"   : @"iPod Touch",        // (Third Generation)
                              @"iPod4,1"   : @"iPod Touch",        // (Fourth Generation)
                              @"iPod7,1"   : @"iPod Touch",        // (6th Generation)
                              @"iPhone1,1" : @"iPhone",            // (Original)
                              @"iPhone1,2" : @"iPhone",            // (3G)
                              @"iPhone2,1" : @"iPhone",            // (3GS)
                              @"iPad1,1"   : @"iPad",              // (Original)
                              @"iPad2,1"   : @"iPad 2",            //
                              @"iPad3,1"   : @"iPad",              // (3rd Generation)
                              @"iPhone3,1" : @"iPhone 4",          // (GSM)
                              @"iPhone3,3" : @"iPhone 4",          // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" : @"iPhone 4s",         //
                              @"iPhone5,1" : @"iPhone 5",          // (model A1428, AT&T/Canada)
                              @"iPhone5,2" : @"iPhone 5",          // (model A1429, everything else)
                              @"iPad3,4"   : @"iPad",              // (4th Generation)
                              @"iPad2,5"   : @"iPad Mini",         // (Original)
                              @"iPhone5,3" : @"iPhone 5c",         // (model A1456, A1532 | GSM)
                              @"iPhone5,4" : @"iPhone 5c",         // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" : @"iPhone 5s",         // (model A1433, A1533 | GSM)
                              @"iPhone6,2" : @"iPhone 5s",         // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" : @"iPhone 6 Plus",     //
                              @"iPhone7,2" : @"iPhone 6",          //
                              @"iPhone8,1" : @"iPhone 6s",         //
                              @"iPhone8,2" : @"iPhone 6s Plus",    //
                              @"iPhone8,4" : @"iPhone SE",         //
                              @"iPhone9,1" : @"iPhone 7",          //
                              @"iPhone9,3" : @"iPhone 7",          //
                              @"iPhone9,2" : @"iPhone 7 Plus",     //
                              @"iPhone9,4" : @"iPhone 7 Plus",     //
                              @"iPhone10,1": @"iPhone 8",          // CDMA
                              @"iPhone10,4": @"iPhone 8",          // GSM
                              @"iPhone10,2": @"iPhone 8 Plus",     // CDMA
                              @"iPhone10,5": @"iPhone 8 Plus",     // GSM
                              @"iPhone10,3": @"iPhone X",          // CDMA
                              @"iPhone10,6": @"iPhone X",          // GSM
                              @"iPhone11,2": @"iPhone XS",         //
                              @"iPhone11,4": @"iPhone XS Max",     //
                              @"iPhone11,6": @"iPhone XS Max",     // China
                              @"iPhone11,8": @"iPhone XR",         //
                              
                              @"iPad4,1"   : @"iPad Air",          // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   : @"iPad Air",          // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   : @"iPad Mini",         // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   : @"iPad Mini",         // (2nd Generation iPad Mini - Cellular)
                              @"iPad4,7"   : @"iPad Mini",         // (3rd Generation iPad Mini - Wifi (model A1599))
                              @"iPad6,7"   : @"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1584)
                              @"iPad6,8"   : @"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1652)
                              @"iPad6,3"   : @"iPad Pro (9.7\")",  // iPad Pro 9.7 inches - (model A1673)
                              @"iPad6,4"   : @"iPad Pro (9.7\")"   // iPad Pro 9.7 inches - (models A1674 and A1675)
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
        else {
            deviceName = @"Unknown";
        }
    }
    
    return deviceName;
}

@end
