//
//  TapView.m
//  RemotePad
//
//  Derived from an Apple's sample code TapView.m of WiTap.
//  Modified by iKawamoto Yosihisa! on 08/08/17.
//
/*

File: TapView.m
Abstract: UIView subclass that can highlight itself when locally or remotely
tapped.

Version: 1.5

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import "TapView.h"
#import "AppController.h"
#import "Constants.h"

//CLASS IMPLEMENTATIONS:

@implementation TapViewController


@synthesize appc;
@synthesize topview;
@synthesize topviewLocation;
@synthesize numberOfButtons;
@synthesize mouseMapLeftToRight;
@synthesize numberArrowKeyGesture;
@synthesize twoFingersScroll;
@synthesize allowHorizontalScroll;
@synthesize clickByTap;
@synthesize dragByTap;
@synthesize dragByTapLock;
@synthesize numberToggleStatusbar;
@synthesize scrollWithMouse3;
@synthesize enableAccelMouse;


- (void)loadView {
	CGRect rect;
	rect = [[UIScreen mainScreen] bounds];
	UIView *view = [[UIView alloc] initWithFrame:rect];
	[view setMultipleTouchEnabled:YES];
	[view setExclusiveTouch:YES];
	[view setBackgroundColor:[UIColor blackColor]];
	self.view = view;
	
	topviewLocation = rect.origin;
	topviewLocation.y += 20;
	topview = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, kButtonHeight)];
	// Disable user interaction for this view. You must do this if you want to handle touches for more than one object at at time.
	// You'll get events for the superview, and then dispatch them to the appropriate subview in the touch handling methods.
	[topview setUserInteractionEnabled:NO];
	[topview setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
	buttonLeftImage = [[[UIImage imageNamed:@"ButtonLeft.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0] retain];
	buttonRightImage = [[[UIImage imageNamed:@"ButtonRight.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0] retain];
	buttonCenterImage = [[[UIImage imageNamed:@"ButtonCenter.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0] retain];
	buttonRoundedImage = [[[UIImage imageNamed:@"ButtonRounded.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0] retain];
	buttonLeftHighlightedImage = [[[UIImage imageNamed:@"ButtonLeftHighlighted.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0] retain];
	buttonRightHighlightedImage = [[[UIImage imageNamed:@"ButtonRightHighlighted.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0] retain];
	buttonCenterHighlightedImage = [[[UIImage imageNamed:@"ButtonCenterHighlighted.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0] retain];
	buttonRoundedHighlightedImage = [[[UIImage imageNamed:@"ButtonRoundedHighlighted.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0] retain];
	mouse1Tap.button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	[mouse1Tap.button setTitle:@"left" forState:UIControlStateNormal];
	[mouse1Tap.button setTitle:@"end drag" forState:UIControlStateSelected];
	[mouse1Tap.button setTitleColor:[mouse1Tap.button titleColorForState:UIControlStateHighlighted] forState:UIControlStateSelected];
	[topview addSubview:mouse1Tap.button];
	mouse3Tap.button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	[mouse3Tap.button setTitle:@"center" forState:UIControlStateNormal];
	[mouse3Tap.button setTitle:@"end drag" forState:UIControlStateSelected];
	[mouse3Tap.button setTitleColor:[mouse3Tap.button titleColorForState:UIControlStateHighlighted] forState:UIControlStateSelected];
	[topview addSubview:mouse3Tap.button];
	mouse2Tap.button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	[mouse2Tap.button setTitle:@"right" forState:UIControlStateNormal];
	[mouse2Tap.button setTitle:@"end drag" forState:UIControlStateSelected];
	[mouse2Tap.button setTitleColor:[mouse2Tap.button titleColorForState:UIControlStateHighlighted] forState:UIControlStateSelected];
	[topview addSubview:mouse2Tap.button];
	[view addSubview:topview];
	bottombar = [[UIToolbar alloc] init];
	[bottombar setBarStyle:UIBarStyleBlackOpaque];
	UIBarButtonItem *toggleButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Hide button" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleToolbars)] autorelease];
	toggleButtonItem.width = kToggleButtonItemWidth;
	UIBarButtonItem *flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	UIBarButtonItem *setupItem = [[[UIBarButtonItem alloc] initWithTitle:@"Setup" style:UIBarButtonItemStyleBordered target:[UIApplication sharedApplication].delegate action:@selector(showSetupView:)] autorelease];
	[bottombar setItems:[NSArray arrayWithObjects:toggleButtonItem, flexItem, setupItem, nil]];
	[bottombar sizeToFit];
	[bottombar setFrame:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, rect.size.width, [bottombar frame].size.height)];
	[view addSubview:bottombar];
	[view release];

	// read defaults
	if (![[NSUserDefaults standardUserDefaults] stringForKey:kDefaultKeyVersion]) {
		[self registerDefaults];
	}
	[self readDefaults];
	
	// initial settting
	[self setNumberOfButtons:numberOfButtons mouseMapLeftToRight:mouseMapLeftToRight];
	if (clickByTap || numberToggleStatusbar == 0) {
		hiddenToolbars = NO;
		hiddenStatusbar = NO;
	} else {
		hiddenToolbars = NO;
		hiddenStatusbar = YES;
	}
	[self prepareToolbarsAndStatusbar];
}

- (void) registerDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultVersion forKey:kDefaultKeyVersion]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultNumberOfButtons forKey:kDefaultKeyNumberOfButtons]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultMouseMapLeftToRight forKey:kDefaultKeyMouseMapLeftToRight]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultNumberArrowKeyGesture forKey:kDefaultKeyNumberArrowKeyGesture]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultTwoFingersScroll forKey:kDefaultKeyTwoFingersScroll]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultAllowHorizontalScroll forKey:kDefaultKeyAllowHorizontalScroll]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultClickByTap forKey:kDefaultKeyClickByTap]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultDragByTap forKey:kDefaultKeyDragByTap]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultDragByTapLock forKey:kDefaultKeyDragByTapLock]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultNumberToggleStatusbar forKey:kDefaultKeyNumberToggleStatusbar]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultNumberToggleToolbars forKey:kDefaultKeyNumberToggleToolbars]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultScrollWithMouse3 forKey:kDefaultKeyScrollWithMouse3]];
	[defaults registerDefaults:[NSDictionary dictionaryWithObject:kDefaultEnableAccelMouse forKey:kDefaultKeyEnableAccelMouse]];
}

- (void) readDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	numberOfButtons = [defaults integerForKey:kDefaultKeyNumberOfButtons];
	if (numberOfButtons < 1 || 3 < numberOfButtons)
		numberOfButtons = 3;
	mouseMapLeftToRight = [defaults boolForKey:kDefaultKeyMouseMapLeftToRight];
	numberArrowKeyGesture = [defaults integerForKey:kDefaultKeyNumberArrowKeyGesture];
	if (numberArrowKeyGesture < 0)
		numberArrowKeyGesture = 0;
	twoFingersScroll = [defaults boolForKey:kDefaultKeyTwoFingersScroll];
	allowHorizontalScroll = [defaults boolForKey:kDefaultKeyAllowHorizontalScroll];
	clickByTap = [defaults boolForKey:kDefaultKeyClickByTap];
	dragByTap = [defaults boolForKey:kDefaultKeyDragByTap];
	dragByTapLock = [defaults boolForKey:kDefaultKeyDragByTapLock];
	numberToggleStatusbar = [defaults integerForKey:kDefaultKeyNumberToggleStatusbar];
	if (numberToggleStatusbar < 0)
		numberToggleStatusbar = 0;
	numberToggleToolbars = [defaults integerForKey:kDefaultKeyNumberToggleToolbars];
	if (numberToggleToolbars < 0)
		numberToggleToolbars = 0;
	scrollWithMouse3 = [defaults boolForKey:kDefaultKeyScrollWithMouse3];
	enableAccelMouse = [defaults boolForKey:kDefaultKeyEnableAccelMouse];
}

- (void) showToolbars:(BOOL)showToolbars showStatusbar:(BOOL)showStatusbar temporal:(BOOL)temporally {
	CGRect rect = [[UIScreen mainScreen] bounds];
	CGRect tbRect;
	if (showToolbars) {
		[[[bottombar items] objectAtIndex:0] setTitle:@"Hide button"];
	} else {
		[[[bottombar items] objectAtIndex:0] setTitle:@"Show button"];
	}
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	tbRect = [topview frame];
	if (showToolbars) {
		[topview setFrame:CGRectMake(topviewLocation.x, topviewLocation.y, tbRect.size.width, tbRect.size.height)];
	} else {
		[topview setFrame:CGRectMake(rect.origin.x, rect.origin.y - tbRect.size.height, tbRect.size.width, tbRect.size.height)];
	}
	if (!temporally)
		hiddenToolbars = !showToolbars;
	tbRect = [bottombar frame];
	if (showStatusbar) {
		[bottombar setFrame:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - tbRect.size.height, tbRect.size.width, tbRect.size.height)];
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	} else {
		[bottombar setFrame:CGRectMake(rect.origin.x, rect.origin.y + rect.size.height, tbRect.size.width, tbRect.size.height)];
		[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	}
	if (!temporally)
		hiddenStatusbar = !showStatusbar;
	[UIView commitAnimations];
}

- (void) showToolbars:(BOOL)show temporal:(BOOL)temporally {
	[self showToolbars:show showStatusbar:!hiddenStatusbar temporal:temporally];
}

- (void)prepareToolbarsAndStatusbar {
	[self showToolbars:!hiddenToolbars showStatusbar:!hiddenStatusbar temporal:NO];
}

- (void)toggleToolbars {
	hiddenToolbars = !hiddenToolbars;
	[self prepareToolbarsAndStatusbar];
}

- (void)toggleStatusbars {
	hiddenStatusbar = !hiddenStatusbar;
	[self prepareToolbarsAndStatusbar];
}

- (void)resetAllStates:(id)applicationControllerDelegate {
	appc = applicationControllerDelegate;
	mouse1Tap.touch = nil;
	mouse2Tap.touch = nil;
	mouse3Tap.touch = nil;
	topviewTap.touch = nil;
	arrowKeyTap.touch = nil;
	mouse1Tap.dragMode = NO;
	mouse2Tap.dragMode = NO;
	mouse3Tap.dragMode = NO;
	topviewTap.dragMode = NO;
	arrowKeyTap.dragMode = NO;
	numTouches = 0;
	phaseHistory[0] = phaseHistory[1] = UITouchPhaseCancelled;
	prevDelta = CGPointZero;
	dragByTapDragMode = NO;
	currAccel.enabled = NO;
	currAccel.stopping = NO;
	currAccel.stability = 0;
	currAccel.ax = currAccel.ay = currAccel.az = 0.0;
	currAccel.vx = currAccel.vy = currAccel.vz = 0.0;
	[clickTimer invalidate];
	clickTimer = nil;
	clickTimerTouch = nil;
}

- (void)setNumberOfButtons:(int)val mouseMapLeftToRight:(BOOL)isLeftToRight {
	numberOfButtons = val;
	mouseMapLeftToRight = isLeftToRight;
	int buttonWidth = [[UIScreen mainScreen] bounds].size.width / numberOfButtons;
	UIImage *mouse1Norm, *mouse1High, *mouse2Norm, *mouse2High;
	if (isLeftToRight) {
		mouse1Norm = buttonLeftImage;
		mouse1High = buttonLeftHighlightedImage;
		mouse2Norm = buttonRightImage;
		mouse2High = buttonRightHighlightedImage;
		[mouse1Tap.button setFrame:CGRectMake(0, 0, buttonWidth, kButtonHeight)];
		[mouse2Tap.button setFrame:CGRectMake(buttonWidth * (numberOfButtons - 1), 0, buttonWidth, kButtonHeight)];
		[mouse3Tap.button setFrame:CGRectMake(buttonWidth, 0, buttonWidth, kButtonHeight)];
	} else {
		mouse1Norm = buttonRightImage;
		mouse1High = buttonRightHighlightedImage;
		mouse2Norm = buttonLeftImage;
		mouse2High = buttonLeftHighlightedImage;
		[mouse1Tap.button setFrame:CGRectMake(buttonWidth * (numberOfButtons - 1), 0, buttonWidth, kButtonHeight)];
		[mouse2Tap.button setFrame:CGRectMake(0, 0, buttonWidth, kButtonHeight)];
		[mouse3Tap.button setFrame:CGRectMake(buttonWidth, 0, buttonWidth, kButtonHeight)];
	}
	switch (numberOfButtons) {
		case 1:
			[mouse1Tap.button setBackgroundImage:buttonRoundedImage forState:UIControlStateNormal];
			[mouse1Tap.button setBackgroundImage:buttonRoundedHighlightedImage forState:UIControlStateSelected];
			[mouse1Tap.button setBackgroundImage:buttonRoundedHighlightedImage forState:UIControlStateHighlighted];
			[mouse2Tap.button setHidden:YES];
			[mouse3Tap.button setHidden:YES];
			break;
		case 2:
			[mouse1Tap.button setBackgroundImage:mouse1Norm forState:UIControlStateNormal];
			[mouse1Tap.button setBackgroundImage:mouse1High forState:UIControlStateSelected];
			[mouse1Tap.button setBackgroundImage:mouse1High forState:UIControlStateHighlighted];
			[mouse2Tap.button setBackgroundImage:mouse2Norm forState:UIControlStateNormal];
			[mouse2Tap.button setBackgroundImage:mouse2High forState:UIControlStateSelected];
			[mouse2Tap.button setBackgroundImage:mouse2High forState:UIControlStateHighlighted];
			[mouse2Tap.button setHidden:NO];
			[mouse3Tap.button setHidden:YES];
			break;
		case 3:
			[mouse1Tap.button setBackgroundImage:mouse1Norm forState:UIControlStateNormal];
			[mouse1Tap.button setBackgroundImage:mouse1High forState:UIControlStateSelected];
			[mouse1Tap.button setBackgroundImage:mouse1High forState:UIControlStateHighlighted];
			[mouse2Tap.button setBackgroundImage:mouse2Norm forState:UIControlStateNormal];
			[mouse2Tap.button setBackgroundImage:mouse2High forState:UIControlStateSelected];
			[mouse2Tap.button setBackgroundImage:mouse2High forState:UIControlStateHighlighted];
			[mouse3Tap.button setBackgroundImage:buttonCenterImage forState:UIControlStateNormal];
			[mouse3Tap.button setBackgroundImage:buttonCenterHighlightedImage forState:UIControlStateSelected];
			[mouse3Tap.button setBackgroundImage:buttonCenterHighlightedImage forState:UIControlStateHighlighted];
			[mouse2Tap.button setHidden:NO];
			[mouse3Tap.button setHidden:NO];
			break;
	}
}

- (void)setNumberOfButtons:(int)val {
	[self setNumberOfButtons:val mouseMapLeftToRight:mouseMapLeftToRight];
}

- (void)setMouseMapLeftToRight:(BOOL)isLeftToRight {
	[self setNumberOfButtons:numberOfButtons mouseMapLeftToRight:isLeftToRight];
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	for (UITouch *touch in touches) {
		CGPoint touchPointForButton = [touch locationInView:topview];
		NSUInteger tapCount = [touch tapCount];
		if (!mouse1Tap.touch && CGRectContainsPoint([mouse1Tap.button frame], touchPointForButton)) {
			[mouse1Tap.button setHighlighted:YES];
			mouse1Tap.touch = touch;
			if (!mouse1Tap.dragMode) {
				[appc send:EVENT_MOUSE_DOWN with:MouseEventValue(0, tapCount) time:event.timestamp];
			} else {
				[mouse1Tap.button setSelected:NO];
				mouse1Tap.dragMode = NO;
			}
		} else if (!mouse2Tap.touch && CGRectContainsPoint([mouse2Tap.button frame], touchPointForButton)) {
			[mouse2Tap.button setHighlighted:YES];
			mouse2Tap.touch = touch;
			if (!mouse2Tap.dragMode) {
				[appc send:EVENT_MOUSE_DOWN with:MouseEventValue(1, tapCount) time:event.timestamp];
			} else {
				[mouse2Tap.button setSelected:NO];
				mouse2Tap.dragMode = NO;
			}
		} else if (!mouse3Tap.touch && CGRectContainsPoint([mouse3Tap.button frame], touchPointForButton)) {
			[mouse3Tap.button setHighlighted:YES];
			mouse3Tap.touch = touch;
			if (!mouse3Tap.dragMode) {
				if (!scrollWithMouse3)
					[appc send:EVENT_MOUSE_DOWN with:MouseEventValue(2, tapCount) time:event.timestamp];
			} else {
				[mouse3Tap.button setSelected:NO];
				mouse3Tap.dragMode = NO;
			}
		} else if (clickByTap) {
			dragByTapDragMode = NO;
			numTouches++;
			if (numTouches == 1) {
				currAccel.enabled = YES;
				currAccel.stopping = NO;
			}
			prevDelta = CGPointZero;
		} else {
			numTouches++;
			if (numTouches == 1) {
				currAccel.enabled = YES;
				currAccel.stopping = NO;
			}
			prevDelta = CGPointZero;
			// Timer for click & drag gestures
			[clickTimer invalidate];
			clickTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(clicked:) userInfo:[NSArray arrayWithObjects:[NSNumber numberWithInt:numTouches], [NSNumber numberWithUnsignedInteger:tapCount], nil] repeats:NO];
			clickTimerTouch = touch;
		}
	}
	phaseHistory[1] = phaseHistory[0];
	phaseHistory[0] = UITouchPhaseBegan;
}

- (void)clicked:(NSTimer*)theTimer {
	int oldNumTouches = [[[theTimer userInfo] objectAtIndex:0] intValue];
	NSUInteger tapCount = [[[theTimer userInfo] objectAtIndex:1] unsignedIntegerValue];
	if (clickTimerTouch != nil) {
		// click and hold or drag
		CGPoint touchPoint = [clickTimerTouch locationInView:self.view];
		if (numberToggleToolbars && numberToggleToolbars == tapCount && !topviewTap.touch && oldNumTouches == 1) {
			if ([clickTimerTouch phase] == UITouchPhaseBegan)
				[self showToolbars:YES temporal:NO];
			topviewTap.touch = clickTimerTouch;
			topviewTap.tapLocation = touchPoint;
			topviewTap.nonDragArea = CGRectMake(touchPoint.x - kOffsetDragBegins, touchPoint.y - kOffsetDragBegins, kOffsetDragBegins * 2, kOffsetDragBegins * 2);
			topviewTap.dragMode = NO;
			numTouches--;
		} else if (numberArrowKeyGesture && numberArrowKeyGesture == tapCount && !arrowKeyTap.touch && oldNumTouches == 1) {
			arrowKeyTap.touch = clickTimerTouch;
			arrowKeyTap.tapLocation = touchPoint;
			arrowKeyTap.nonDragArea = CGRectMake(touchPoint.x - kOffsetDragBegins, touchPoint.y - kOffsetDragBegins, kOffsetDragBegins * 2, kOffsetDragBegins * 2);
			arrowKeyTap.dragMode = NO;
			numTouches--;
		}
	} else {
		// click and release
		if (numberToggleStatusbar && numberToggleStatusbar == tapCount && oldNumTouches == 1)
			[self toggleStatusbars];
		else if (numberToggleToolbars && numberToggleToolbars == tapCount && oldNumTouches == 1)
			[self toggleToolbars];
	}
	clickTimer = nil;
	clickTimerTouch = nil;
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	for (UITouch *touch in touches) {
		NSUInteger tapCount = [touch tapCount];
		if (touch == mouse1Tap.touch) {
			[appc send:EVENT_MOUSE_UP with:MouseEventValue(0, tapCount) time:event.timestamp];
			[mouse1Tap.button setHighlighted:NO];
			mouse1Tap.touch = nil;
		} else if (touch == mouse2Tap.touch) {
			[appc send:EVENT_MOUSE_UP with:MouseEventValue(1, tapCount) time:event.timestamp];
			[mouse2Tap.button setHighlighted:NO];
			mouse2Tap.touch = nil;
		} else if (touch == mouse3Tap.touch) {
			if (!scrollWithMouse3)
				[appc send:EVENT_MOUSE_UP with:MouseEventValue(2, tapCount) time:event.timestamp];
			[mouse3Tap.button setHighlighted:NO];
			mouse3Tap.touch = nil;
		} else if (clickByTap) {
			numTouches--;
			if (numTouches == 0)
				currAccel.stopping = YES;
			prevDelta = CGPointZero;
			if (tapCount > 0 && numTouches == 0 && phaseHistory[0] == UITouchPhaseBegan) {
				if (mouse1Tap.dragMode) {
					[appc send:EVENT_MOUSE_UP with:MouseEventValue(0, tapCount) time:event.timestamp];
					[mouse1Tap.button setSelected:NO];
					mouse1Tap.dragMode = NO;
				} else if (mouse2Tap.dragMode) {
					[appc send:EVENT_MOUSE_UP with:MouseEventValue(1, tapCount) time:event.timestamp];
					[mouse2Tap.button setSelected:NO];
					mouse2Tap.dragMode = NO;
				} else if (mouse3Tap.dragMode) {
					[appc send:EVENT_MOUSE_UP with:MouseEventValue(2, tapCount) time:event.timestamp];
					[mouse3Tap.button setSelected:NO];
					mouse3Tap.dragMode = NO;
				} else if (dragByTapDragMode && dragByTapLock) {
					[appc send:EVENT_MOUSE_UP with:MouseEventValue(0, tapCount) time:event.timestamp];
					dragByTapDragMode = NO;
				} else {
					[appc send:EVENT_MOUSE_DOWN with:MouseEventValue(0, tapCount) time:event.timestamp];
					[appc send:EVENT_MOUSE_UP with:MouseEventValue(0, tapCount) time:event.timestamp];
				}
			} else if (dragByTapDragMode && !dragByTapLock) {
				[appc send:EVENT_MOUSE_UP with:MouseEventValue(0, tapCount) time:event.timestamp];
				dragByTapDragMode = NO;
			}
		} else if (touch == topviewTap.touch) {
			topviewTap.touch = nil;
		} else if (touch == arrowKeyTap.touch) {
			arrowKeyTap.touch = nil;
		} else {
			numTouches--;
			if (numTouches == 0)
				currAccel.stopping = YES;
			prevDelta = CGPointZero;
			// Timer for click & drag gestures
			if (clickTimerTouch == touch)
				clickTimerTouch = nil;
		}
	}
	phaseHistory[1] = phaseHistory[0];
	phaseHistory[0] = UITouchPhaseEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
	phaseHistory[0] = UITouchPhaseCancelled;
	// Extra cancellings may come out
	if (numTouches < 0)
		numTouches = 0;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([clickTimer isValid])
		[clickTimer fire];
	for (UITouch *touch in touches) {
		CGPoint touchPoint = [touch locationInView:self.view];
		CGPoint touchPointForButton = [touch locationInView:topview];
		CGPoint prevPoint = [touch previousLocationInView:self.view];
		if (touch == mouse1Tap.touch) {
			if (!mouse1Tap.dragMode && !CGRectContainsPoint([mouse1Tap.button frame], touchPointForButton)) {
				[mouse1Tap.button setSelected:YES];
				[mouse1Tap.button setHighlighted:NO];
				mouse1Tap.dragMode = YES;
				mouse1Tap.touch = nil;
				numTouches++;
				if (numTouches == 1) {
					currAccel.enabled = YES;
					currAccel.stopping = NO;
				}
			}
		} else if (touch == mouse2Tap.touch) {
			if (!mouse2Tap.dragMode && !CGRectContainsPoint([mouse2Tap.button frame], touchPointForButton)) {
				[mouse2Tap.button setSelected:YES];
				[mouse2Tap.button setHighlighted:NO];
				mouse2Tap.dragMode = YES;
				mouse2Tap.touch = nil;
				numTouches++;
				if (numTouches == 1) {
					currAccel.enabled = YES;
					currAccel.stopping = NO;
				}
			}
		} else if (touch == mouse3Tap.touch) {
			if (!mouse3Tap.dragMode && !CGRectContainsPoint([mouse3Tap.button frame], touchPointForButton)) {
				[mouse3Tap.button setSelected:YES];
				[mouse3Tap.button setHighlighted:NO];
				mouse3Tap.dragMode = YES;
				mouse3Tap.touch = nil;
				numTouches++;
				if (numTouches == 1) {
					currAccel.enabled = YES;
					currAccel.stopping = NO;
				}
			}
		} else if (touch == topviewTap.touch) {
			if (topviewTap.dragMode || !CGRectContainsPoint(topviewTap.nonDragArea, touchPoint)) {
				topviewTap.dragMode = YES;
				topviewLocation = CGPointMake(topviewLocation.x, touchPoint.y - [topview bounds].size.height/2);
				[self showToolbars:YES temporal:YES];
			}
		} else if (touch == arrowKeyTap.touch) {
			if (!CGRectContainsPoint(arrowKeyTap.nonDragArea, touchPoint)) {
				arrowKeyTap.dragMode = YES;
				int32_t keycode;
				if (arrowKeyTap.tapLocation.y - touchPoint.y > abs(touchPoint.x - arrowKeyTap.tapLocation.x)) {
					keycode = kKeycodeUp;
				} else if (touchPoint.y - arrowKeyTap.tapLocation.y > abs(touchPoint.x - arrowKeyTap.tapLocation.x)) {
					keycode = kKeycodeDown;
				} else if (arrowKeyTap.tapLocation.x > touchPoint.x) {
					keycode = kKeycodeLeft;
				} else {
					keycode = kKeycodeRight;
				}
				[appc send:EVENT_KEY_DOWN with:keycode time:event.timestamp];
				[appc send:EVENT_KEY_UP with:keycode time:event.timestamp];
				arrowKeyTap.tapLocation = touchPoint;
				arrowKeyTap.nonDragArea = CGRectMake(touchPoint.x - kOffsetDragBegins, touchPoint.y - kOffsetDragBegins, kOffsetDragBegins * 2, kOffsetDragBegins * 2);
			}
		} else if (numTouches == 2 || scrollWithMouse3 && mouse3Tap.dragMode && numTouches == 1) {
			if (twoFingersScroll || numTouches == 1) {
				CGPoint delta = CGPointMake(touchPoint.x - prevPoint.x, touchPoint.y - prevPoint.y);
				if (allowHorizontalScroll)
					[appc send:EVENT_MOUSE_DELTA_W with:(delta.x + prevDelta.x) / 2 time:event.timestamp];
				[appc send:EVENT_MOUSE_DELTA_Z with:(delta.y + prevDelta.y) / 2 time:event.timestamp];
				prevDelta = delta;
			}
		} else if (numTouches == 1) {
			NSUInteger tapCount = [touch tapCount];
			if (dragByTap && clickByTap && !dragByTapDragMode && tapCount > 1) {
				[appc send:EVENT_MOUSE_DOWN with:MouseEventValue(0, tapCount) time:event.timestamp];
				dragByTapDragMode = YES;
			}
			if (phaseHistory[0] == UITouchPhaseBegan) {
				// ignore first move
				phaseHistory[1] = phaseHistory[0];
				phaseHistory[0] = UITouchPhaseMoved;
				continue;
			}
			CGPoint delta = CGPointMake(touchPoint.x - prevPoint.x, touchPoint.y - prevPoint.y);
			[appc send:EVENT_MOUSE_DELTA_X with:(delta.x + prevDelta.x) / 2 time:event.timestamp];
			[appc send:EVENT_MOUSE_DELTA_Y with:(delta.y + prevDelta.y) / 2 time:event.timestamp];
			prevDelta = delta;
		}
	}
	phaseHistory[1] = phaseHistory[0];
	phaseHistory[0] = UITouchPhaseMoved;
}


// UIAccelerometerDelegate method, called when the device accelerates.
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	if (!enableAccelMouse)
		return;
	// pseudo high pass filter
	currAccel.ax = acceleration.x * kFilteringFactor + currAccel.ax * (1.0 - kFilteringFactor);
	currAccel.ay = acceleration.y * kFilteringFactor + currAccel.ay * (1.0 - kFilteringFactor);
	currAccel.az = acceleration.z * kFilteringFactor + currAccel.az * (1.0 - kFilteringFactor);
	UIAccelerationValue dx = acceleration.x - currAccel.ax, dy = acceleration.y - currAccel.ay, dz = acceleration.z - currAccel.az;
	// check if iphone is stable or not
	currAccel.stability = currAccel.stability * kAccelerationStabilityFactor + dx*dx + dy*dy + dz*dz;
	if (!currAccel.enabled)
		return;
	int32_t deltaX, deltaY;
	if (currAccel.stopping || currAccel.stability < 0.1) {
		currAccel.vx = currAccel.vx * kAccelerationReleaseFactor;
		currAccel.vy = currAccel.vy * kAccelerationReleaseFactor;
		currAccel.vz = currAccel.vz * kAccelerationReleaseFactor;
	} else {
		// changing current velocity smoothly
		currAccel.vx = currAccel.vx * kAccelerationSmoothFactor + dx;
		currAccel.vy = currAccel.vy * kAccelerationSmoothFactor + dy;
		currAccel.vz = currAccel.vz * kAccelerationSmoothFactor + dz;
	}
	deltaX = currAccel.vx * kHorizontalAccelerationFactor;
	deltaY = -currAccel.vz * kVerticalAccelerationFactor;
	if (deltaX == 0 && deltaY == 0) {
		currAccel.enabled = !currAccel.stopping;
	} else {
		[appc send:EVENT_MOUSE_DELTA_X with:deltaX time:acceleration.timestamp];
		[appc send:EVENT_MOUSE_DELTA_Y with:deltaY time:acceleration.timestamp];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[topview release];
	[bottombar release];
	[mouse1Tap.button release];
	[mouse2Tap.button release];
	[mouse3Tap.button release];
	[buttonLeftImage release];
	[buttonRightImage release];
	[buttonCenterImage release];
	[buttonRoundedImage release];
	[buttonLeftHighlightedImage release];
	[buttonRightHighlightedImage release];
	[buttonCenterHighlightedImage release];
	[buttonRoundedHighlightedImage release];
	[super dealloc];
}


@end