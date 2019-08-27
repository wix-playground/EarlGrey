//
// Copyright 2016 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Action/GREYActions.h"

#import <WebKit/WebKit.h>

#import "Action/GREYAction.h"
#import "Action/GREYActionBlock.h"
#import "Action/GREYChangeStepperAction.h"
#import "Action/GREYMultiFingerSwipeAction.h"
#import "Action/GREYPickerAction.h"
#import "Action/GREYPinchAction.h"
#import "Action/GREYScrollAction.h"
#import "Action/GREYScrollToContentEdgeAction.h"
#import "Action/GREYSlideAction.h"
#import "Action/GREYSwipeAction.h"
#import "Action/GREYTapAction.h"
#import "Additions/NSError+GREYAdditions.h"
#import "Additions/NSObject+GREYAdditions.h"
#import "Additions/NSString+GREYAdditions.h"
#import "Additions/UISwitch+GREYAdditions.h"
#import "Assertion/GREYAssertionDefines.h"
#import "Common/GREYAppleInternals.h"
#import "Common/GREYError.h"
#import "Common/GREYScreenshotUtil.h"
#import "Common/GREYThrowDefines.h"
#import "Core/GREYInteraction.h"
#import "Matcher/GREYAllOf.h"
#import "Matcher/GREYAnyOf.h"
#import "Matcher/GREYMatcher.h"
#import "Matcher/GREYMatchers.h"
#import "Matcher/GREYNot.h"

static Class gWebAccessibilityObjectWrapperClass;
static Class gAccessibilityTextFieldElementClass;

@implementation GREYActions

+ (void)initialize {
  if (self == [GREYActions class]) {
    gWebAccessibilityObjectWrapperClass = NSClassFromString(@"WebAccessibilityObjectWrapper");
    gAccessibilityTextFieldElementClass = NSClassFromString(@"UIAccessibilityTextFieldElement");
  }
}

+ (id<GREYAction>)actionForSwipeFastInDirection:(GREYDirection)direction {
  return [[GREYSwipeAction alloc] initWithDirection:direction duration:kGREYSwipeFastDuration];
}

+ (id<GREYAction>)actionForSwipeSlowInDirection:(GREYDirection)direction {
  return [[GREYSwipeAction alloc] initWithDirection:direction duration:kGREYSwipeSlowDuration];
}

+ (id<GREYAction>)actionForSwipeFastInDirection:(GREYDirection)direction
                         xOriginStartPercentage:(CGFloat)xOriginStartPercentage
                         yOriginStartPercentage:(CGFloat)yOriginStartPercentage {
  return [[GREYSwipeAction alloc] initWithDirection:direction
                                           duration:kGREYSwipeFastDuration
                                      startPercents:CGPointMake(xOriginStartPercentage,
                                                                yOriginStartPercentage)];
}

+ (id<GREYAction>)actionForSwipeSlowInDirection:(GREYDirection)direction
                         xOriginStartPercentage:(CGFloat)xOriginStartPercentage
                         yOriginStartPercentage:(CGFloat)yOriginStartPercentage {
  return [[GREYSwipeAction alloc] initWithDirection:direction
                                           duration:kGREYSwipeSlowDuration
                                      startPercents:CGPointMake(xOriginStartPercentage,
                                                                yOriginStartPercentage)];
}

+ (id<GREYAction>)actionForMultiFingerSwipeSlowInDirection:(GREYDirection)direction
                                           numberOfFingers:(NSUInteger)numberOfFingers {
  return [[GREYMultiFingerSwipeAction alloc] initWithDirection:direction
                                                      duration:kGREYSwipeSlowDuration
                                               numberOfFingers:numberOfFingers];
}

+ (id<GREYAction>)actionForMultiFingerSwipeFastInDirection:(GREYDirection)direction
                                           numberOfFingers:(NSUInteger)numberOfFingers {
  return [[GREYMultiFingerSwipeAction alloc] initWithDirection:direction
                                                      duration:kGREYSwipeFastDuration
                                               numberOfFingers:numberOfFingers];
}

+ (id<GREYAction>)actionForMultiFingerSwipeSlowInDirection:(GREYDirection)direction
                                           numberOfFingers:(NSUInteger)numberOfFingers
                                    xOriginStartPercentage:(CGFloat)xOriginStartPercentage
                                    yOriginStartPercentage:(CGFloat)yOriginStartPercentage {
  return [[GREYMultiFingerSwipeAction alloc] initWithDirection:direction
                                                      duration:kGREYSwipeSlowDuration
                                               numberOfFingers:numberOfFingers
                                                 startPercents:CGPointMake(xOriginStartPercentage,
                                                                           yOriginStartPercentage)];
}

+ (id<GREYAction>)actionForMultiFingerSwipeFastInDirection:(GREYDirection)direction
                                           numberOfFingers:(NSUInteger)numberOfFingers
                                    xOriginStartPercentage:(CGFloat)xOriginStartPercentage
                                    yOriginStartPercentage:(CGFloat)yOriginStartPercentage {
  return [[GREYMultiFingerSwipeAction alloc] initWithDirection:direction
                                                      duration:kGREYSwipeFastDuration
                                               numberOfFingers:numberOfFingers
                                                 startPercents:CGPointMake(xOriginStartPercentage,
                                                                           yOriginStartPercentage)];
}

+ (id<GREYAction>)actionForPinchFastInDirection:(GREYPinchDirection)pinchDirection
                                      withAngle:(double)angle {
  return [[GREYPinchAction alloc] initWithDirection:pinchDirection
                                           duration:kGREYPinchFastDuration
                                         pinchAngle:angle];
}

+ (id<GREYAction>)actionForPinchSlowInDirection:(GREYPinchDirection)pinchDirection
                                      withAngle:(double)angle {
  return [[GREYPinchAction alloc] initWithDirection:pinchDirection
                                           duration:kGREYPinchSlowDuration
                                         pinchAngle:angle];
}

+ (id<GREYAction>)actionForMoveSliderToValue:(float)value {
  return [[GREYSlideAction alloc] initWithSliderValue:value];
}

+ (id<GREYAction>)actionForSetStepperValue:(double)value {
  return [[GREYChangeStepperAction alloc] initWithValue:value];
}

+ (id<GREYAction>)actionForTap {
  return [[GREYTapAction alloc] initWithType:kGREYTapTypeShort];
}

+ (id<GREYAction>)actionForTapAtPoint:(CGPoint)point {
  return [[GREYTapAction alloc] initWithType:kGREYTapTypeShort numberOfTaps:1 location:point];
}

+ (id<GREYAction>)actionForLongPress {
  return [GREYActions actionForLongPressWithDuration:kGREYLongPressDefaultDuration];
}

+ (id<GREYAction>)actionForLongPressWithDuration:(CFTimeInterval)duration {
  return [[GREYTapAction alloc] initLongPressWithDuration:duration];
}

+ (id<GREYAction>)actionForLongPressAtPoint:(CGPoint)point duration:(CFTimeInterval)duration {
  return [[GREYTapAction alloc] initLongPressWithDuration:duration location:point];
}

+ (id<GREYAction>)actionForMultipleTapsWithCount:(NSUInteger)count {
  return [[GREYTapAction alloc] initWithType:kGREYTapTypeMultiple numberOfTaps:count];
}

+ (id<GREYAction>)actionForMultipleTapsWithCount:(NSUInteger)count atPoint:(CGPoint)point {
  return [[GREYTapAction alloc] initWithType:kGREYTapTypeMultiple
                                numberOfTaps:count
                                    location:point];
}

// The |amount| is in points
+ (id<GREYAction>)actionForScrollInDirection:(GREYDirection)direction amount:(CGFloat)amount {
  return [[GREYScrollAction alloc] initWithDirection:direction amount:amount];
}

+ (id<GREYAction>)actionForScrollInDirection:(GREYDirection)direction
                                      amount:(CGFloat)amount
                      xOriginStartPercentage:(CGFloat)xOriginStartPercentage
                      yOriginStartPercentage:(CGFloat)yOriginStartPercentage {
  return [[GREYScrollAction alloc] initWithDirection:direction
                                              amount:amount
                                  startPointPercents:CGPointMake(xOriginStartPercentage,
                                                                 yOriginStartPercentage)];
}

+ (id<GREYAction>)actionForScrollToContentEdge:(GREYContentEdge)edge {
  return [[GREYScrollToContentEdgeAction alloc] initWithEdge:edge];
}

+ (id<GREYAction>)actionForScrollToContentEdge:(GREYContentEdge)edge
                        xOriginStartPercentage:(CGFloat)xOriginStartPercentage
                        yOriginStartPercentage:(CGFloat)yOriginStartPercentage {
  return [[GREYScrollToContentEdgeAction alloc] initWithEdge:edge
                                          startPointPercents:CGPointMake(xOriginStartPercentage,
                                                                         yOriginStartPercentage)];
}

+ (id<GREYAction>)actionForTurnSwitchOn:(BOOL)on {
  id<GREYMatcher> constraints = grey_allOf(grey_not(grey_systemAlertViewShown()),
                                           grey_respondsToSelector(@selector(isOn)), nil);
  NSString *actionName = [NSString stringWithFormat:@"Turn switch to %@ state",
                             [UISwitch grey_stringFromOnState:on]];
  return [GREYActionBlock actionWithName:actionName
                             constraints:constraints
                            performBlock:^BOOL (id switchView, __strong NSError **errorOrNil) {
    if (([switchView isOn] && !on) || (![switchView isOn] && on)) {
      id<GREYAction> longPressAction =
          [GREYActions actionForLongPressWithDuration:kGREYLongPressDefaultDuration];
      return [longPressAction perform:switchView error:errorOrNil];
    }
    return YES;
  }];
}

+ (id<GREYAction>)actionForTypeText:(NSString *)text {
  return [GREYActions grey_actionForTypeText:text atUITextPosition:nil];
}

+ (id<GREYAction>)actionForReplaceText:(NSString *)text {
  return [GREYActions grey_actionForReplaceText:text];
}

+ (id<GREYAction>)actionForClearText {
  id<GREYMatcher> constraints =
      grey_anyOf(grey_respondsToSelector(@selector(text)),
                 grey_kindOfClass(gAccessibilityTextFieldElementClass),
                 grey_kindOfClass(gWebAccessibilityObjectWrapperClass),
                 grey_conformsToProtocol(@protocol(UITextInput)),
                 nil);
  return [GREYActionBlock actionWithName:@"Clear text"
                             constraints:constraints
                            performBlock:^BOOL (id element, __strong NSError **errorOrNil) {
    NSString *textStr;
    if ([element grey_isWebAccessibilityElement]) {
      [GREYActions grey_setText:@"" onWebElement:element];
      return YES;
    } else if ([element isKindOfClass:gAccessibilityTextFieldElementClass]) {
      element = [element textField];
    } else if ([element respondsToSelector:@selector(text)]) {
      textStr = [element text];
    } else {
      UITextRange *range = [element textRangeFromPosition:[element beginningOfDocument]
                                               toPosition:[element endOfDocument]];
      textStr = [element textInRange:range];
    }

    NSMutableString *deleteStr = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < textStr.length; i++) {
      [deleteStr appendString:@"\b"];
    }

    if (deleteStr.length == 0) {
      return YES;
    } else if ([element conformsToProtocol:@protocol(UITextInput)]) {
      id<GREYAction> typeAtEnd = [GREYActions grey_actionForTypeText:deleteStr
                                                    atUITextPosition:[element endOfDocument]];
      return [typeAtEnd perform:element error:errorOrNil];
    } else {
      return [[GREYActions actionForTypeText:deleteStr] perform:element error:errorOrNil];
    }
  }];
}

+ (id<GREYAction>)actionForSetDate:(NSDate *)date {
  id<GREYMatcher> constraints = grey_allOf(grey_interactable(),
                                           grey_not(grey_systemAlertViewShown()),
                                           grey_kindOfClass([UIDatePicker class]),
                                           nil);
  return [[GREYActionBlock alloc] initWithName:[NSString stringWithFormat:@"Set date to %@", date]
                                   constraints:constraints
                                  performBlock:^BOOL (UIDatePicker *datePicker,
                                                      __strong NSError **errorOrNil) {
    NSDate *previousDate = [datePicker date];
    [datePicker setDate:date animated:YES];
    // Changing the data programmatically does not fire the "value changed" events,
    // So we have to trigger the events manually if the value changes.
    if (![date isEqualToDate:previousDate]) {
      [datePicker sendActionsForControlEvents:UIControlEventValueChanged];
    }
    return YES;
  }];
}

+ (id<GREYAction>)actionForSetPickerColumn:(NSInteger)column toValue:(NSString *)value {
  return [[GREYPickerAction alloc] initWithColumn:column value:value];
}

+ (id<GREYAction>)actionForSnapshot:(__strong UIImage **)outImage {
  GREYThrowOnNilParameter(outImage);

  return [[GREYActionBlock alloc] initWithName:@"Element Snapshot"
                                   constraints:nil
                                  performBlock:^BOOL (id element, __strong NSError **errorOrNil) {
    UIImage *snapshot = [GREYScreenshotUtil snapshotElement:element];
    if (snapshot == nil) {
      GREYPopulateErrorOrLog(errorOrNil,
                             kGREYInteractionErrorDomain,
                             kGREYInteractionActionFailedErrorCode,
                             @"Failed to take snapshot. Snapshot is nil.");
      return NO;
    } else {
      *outImage = snapshot;
      return YES;
    }
  }];
}

#pragma mark - Private

/**
 *  Sets WebView input text value.
 *
 *  @param element The element to target
 *  @param text The text to set
 */
+ (void)grey_setText:(NSString *)text onWebElement:(id)element {
  // Input tags can be identified by having the 'title' attribute set, or current value.
  // Associating a <label> tag to the input tag does NOT result in an iOS accessibility element.
  if (!text) {
    text = @"";
  }
  // Must escape ' or the JS will be invalid.
  text = [text stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];

  NSString *xPathResultType = @"XPathResult.FIRST_ORDERED_NODE_TYPE";
  NSString *xPathForTitle = [NSString stringWithFormat:@"//input[@title=\"%@\" or @value=\"%@\"]",
                                                       [element accessibilityLabel],
                                                       [element accessibilityLabel]];
  NSString *format = @"document.evaluate('%@', document, null, %@, null).singleNodeValue.value"
                     @"= '%@';";
  NSString *jsForTitle = [[NSString alloc] initWithFormat:format,
                                                          xPathForTitle,
                                                          xPathResultType,
                                                          text];
  UIWebView *parentWebView = (UIWebView *)[element grey_viewContainingSelf];
  [parentWebView stringByEvaluatingJavaScriptFromString:jsForTitle];
}

/**
 *  Set the UITextField text value directly, bypassing the iOS keyboard.
 *
 *  @param text The text to be typed.
 *
 *  @return @c YES if the action succeeded, else @c NO. If an action returns @c NO, it does not
 *          mean that the action was not performed at all but somewhere during the action execution
 *          the error occurred and so the UI may be in an unrecoverable state.
 */
+ (id<GREYAction>)grey_actionForReplaceText:(NSString *)text {
  SEL setTextSelector = NSSelectorFromString(@"setText:");
  id<GREYMatcher> constraints =
      grey_anyOf(grey_respondsToSelector(setTextSelector),
                 grey_kindOfClass(gAccessibilityTextFieldElementClass),
                 grey_kindOfClass(gWebAccessibilityObjectWrapperClass),
                 nil);
  NSString *replaceActionName = [NSString stringWithFormat:@"Replace with text: \"%@\"", text];
  return [GREYActionBlock actionWithName:replaceActionName
                             constraints:constraints
                            performBlock:^BOOL (id element, __strong NSError **errorOrNil) {
    if ([element grey_isWebAccessibilityElement]) {
      [GREYActions grey_setText:text onWebElement:element];
    } else {
      if ([element isKindOfClass:gAccessibilityTextFieldElementClass]) {
        element = [element textField];
      }
      BOOL elementIsUIControl = [element isKindOfClass:[UIControl class]];
      BOOL elementIsUITextField = [element isKindOfClass:[UITextField class]];

      // Did begin editing notifications.
      if (elementIsUIControl) {
        [element sendActionsForControlEvents:UIControlEventEditingDidBegin];
      }

      if (elementIsUITextField) {
        NSNotification *notification =
            [NSNotification notificationWithName:UITextFieldTextDidBeginEditingNotification
                                          object:element];
        [NSNotificationCenter.defaultCenter postNotification:notification];
      }

      // Actually change the text.
      [element setText:text];

      // Did change editing notifications.
      if (elementIsUIControl) {
        [element sendActionsForControlEvents:UIControlEventEditingChanged];
      }
      if (elementIsUITextField) {
        NSNotification *notification =
            [NSNotification notificationWithName:UITextFieldTextDidChangeNotification
                                          object:element];
        [NSNotificationCenter.defaultCenter postNotification:notification];
      }

      // Did end editing notifications.
      if (elementIsUIControl) {
        [element sendActionsForControlEvents:UIControlEventEditingDidEndOnExit];
        [element sendActionsForControlEvents:UIControlEventEditingDidEnd];
      }
      if (elementIsUITextField) {
        NSNotification *notification =
            [NSNotification notificationWithName:UITextFieldTextDidEndEditingNotification
                                          object:element];
        [NSNotificationCenter.defaultCenter postNotification:notification];
      }
    }
    return YES;
  }];
}

#pragma mark - Package Internal

+ (id<GREYAction>)grey_actionForTypeText:(NSString *)text
                        atUITextPosition:(UITextPosition *)position {
	return nil;
}

@end

#if !(GREY_DISABLE_SHORTHAND)

id<GREYAction> grey_doubleTap(void) {
  return [GREYActions actionForMultipleTapsWithCount:2];
}

id<GREYAction> grey_doubleTapAtPoint(CGPoint point) {
  return [GREYActions actionForMultipleTapsWithCount:2 atPoint:point];
}

id<GREYAction> grey_multipleTapsWithCount(NSUInteger count) {
  return [GREYActions actionForMultipleTapsWithCount:count];
}

id<GREYAction> grey_longPress(void) {
  return [GREYActions actionForLongPress];
}

id<GREYAction> grey_longPressWithDuration(CFTimeInterval duration) {
  return [GREYActions actionForLongPressWithDuration:duration];
}

id<GREYAction> grey_longPressAtPointWithDuration(CGPoint point, CFTimeInterval duration) {
  return [GREYActions actionForLongPressAtPoint:point duration:duration];
}

id<GREYAction> grey_scrollInDirection(GREYDirection direction, CGFloat amount) {
  return [GREYActions actionForScrollInDirection:direction amount:amount];
}

id<GREYAction> grey_scrollInDirectionWithStartPoint(GREYDirection direction,
                                                    CGFloat amount,
                                                    CGFloat xOriginStartPercentage,
                                                    CGFloat yOriginStartPercentage) {
  return [GREYActions actionForScrollInDirection:direction
                                          amount:amount
                          xOriginStartPercentage:xOriginStartPercentage
                          yOriginStartPercentage:yOriginStartPercentage];
}

id<GREYAction> grey_scrollToContentEdge(GREYContentEdge edge) {
  return [GREYActions actionForScrollToContentEdge:edge];
}

id<GREYAction> grey_scrollToContentEdgeWithStartPoint(GREYContentEdge edge,
                                                      CGFloat xOriginStartPercentage,
                                                      CGFloat yOriginStartPercentage) {
  return [GREYActions actionForScrollToContentEdge:edge
                            xOriginStartPercentage:xOriginStartPercentage
                            yOriginStartPercentage:yOriginStartPercentage];
}

id<GREYAction> grey_swipeFastInDirection(GREYDirection direction) {
  return [GREYActions actionForSwipeFastInDirection:direction];
}

id<GREYAction> grey_swipeSlowInDirection(GREYDirection direction) {
  return [GREYActions actionForSwipeSlowInDirection:direction];
}

id<GREYAction> grey_swipeFastInDirectionWithStartPoint(GREYDirection direction,
                                                       CGFloat xOriginStartPercentage,
                                                       CGFloat yOriginStartPercentage) {
  return [GREYActions actionForSwipeFastInDirection:direction
                             xOriginStartPercentage:xOriginStartPercentage
                             yOriginStartPercentage:yOriginStartPercentage];
}

id<GREYAction> grey_swipeSlowInDirectionWithStartPoint(GREYDirection direction,
                                                       CGFloat xOriginStartPercentage,
                                                       CGFloat yOriginStartPercentage) {
  return [GREYActions actionForSwipeSlowInDirection:direction
                             xOriginStartPercentage:xOriginStartPercentage
                             yOriginStartPercentage:yOriginStartPercentage];
}

id<GREYAction> grey_multiFingerSwipeSlowInDirection(GREYDirection direction,
                                                    NSUInteger numberOfFingers) {
  return [GREYActions actionForMultiFingerSwipeSlowInDirection:direction
                                               numberOfFingers:numberOfFingers];
}

id<GREYAction> grey_multiFingerSwipeFastInDirection(GREYDirection direction,
                                                    NSUInteger numberOfFingers) {
  return [GREYActions actionForMultiFingerSwipeFastInDirection:direction
                                               numberOfFingers:numberOfFingers];
}

id<GREYAction> grey_multiFingerSwipeSlowInDirectionWithStartPoint(GREYDirection direction,
                                                                  NSUInteger numberOfFingers,
                                                                  CGFloat xOriginStartPercentage,
                                                                  CGFloat yOriginStartPercentage) {
  return [GREYActions actionForMultiFingerSwipeSlowInDirection:direction
                                               numberOfFingers:numberOfFingers
                                        xOriginStartPercentage:xOriginStartPercentage
                                        yOriginStartPercentage:yOriginStartPercentage];
}

id<GREYAction> grey_multiFingerSwipeFastInDirectionWithStartPoint(GREYDirection direction,
                                                                  NSUInteger numberOfFingers,
                                                                  CGFloat xOriginStartPercentage,
                                                                  CGFloat yOriginStartPercentage) {
  return [GREYActions actionForMultiFingerSwipeFastInDirection:direction
                                               numberOfFingers:numberOfFingers
                                        xOriginStartPercentage:xOriginStartPercentage
                                        yOriginStartPercentage:yOriginStartPercentage];
}

id<GREYAction> grey_pinchFastInDirectionAndAngle(GREYPinchDirection pinchDirection,
                                                 double angle) {
  return [GREYActions actionForPinchFastInDirection:pinchDirection withAngle:angle];
}

id<GREYAction> grey_pinchSlowInDirectionAndAngle(GREYPinchDirection pinchDirection,
                                                 double angle) {
  return [GREYActions actionForPinchSlowInDirection:pinchDirection withAngle:angle];
}

id<GREYAction> grey_moveSliderToValue(float value) {
  return [GREYActions actionForMoveSliderToValue:value];
}

id<GREYAction> grey_setStepperValue(double value) {
  return [GREYActions actionForSetStepperValue:value];
}

id<GREYAction> grey_tap(void) {
  return [GREYActions actionForTap];
}

id<GREYAction> grey_tapAtPoint(CGPoint point) {
  return [GREYActions actionForTapAtPoint:point];
}

id<GREYAction> grey_typeText(NSString *text) {
  return [GREYActions actionForTypeText:text];
}

id<GREYAction> grey_replaceText(NSString *text) {
  return [GREYActions actionForReplaceText:text];
}

id<GREYAction> grey_clearText(void) {
  return [GREYActions actionForClearText];
}

id<GREYAction> grey_turnSwitchOn(BOOL on) {
  return [GREYActions actionForTurnSwitchOn:on];
}

id<GREYAction> grey_setDate(NSDate *date) {
  return [GREYActions actionForSetDate:date];
}

id<GREYAction> grey_setPickerColumnToValue(NSInteger column, NSString *value) {
  return [GREYActions actionForSetPickerColumn:column toValue:value];
}

id<GREYAction> grey_snapshot(__strong UIImage **outImage) {
  return [GREYActions actionForSnapshot:outImage];
}

#endif // GREY_DISABLE_SHORTHAND
