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

#import "Additions/NSObject+GREYAdditions.h"

#include <objc/runtime.h>

#import "Additions/CGGeometry+GREYAdditions.h"
#import "Additions/NSString+GREYAdditions.h"
#import "Assertion/GREYAssertionDefines.h"
#import "Common/GREYConfiguration.h"
#import "Common/GREYConstants.h"
#import "Common/GREYElementHierarchy.h"
#import "Common/GREYFatalAsserts.h"
#import "Common/GREYLogger.h"
#import "Common/GREYSwizzler.h"

/**
 *  Class that all Web Accessibility Elements have to be a kind of.
 */
static Class gWebAccessibilityWrapper;

@implementation NSObject (GREYAdditions)

- (NSString *)grey_recursiveDescription {
  if ([self grey_isWebAccessibilityElement]) {
    return [GREYElementHierarchy hierarchyStringForElement:[self grey_viewContainingSelf]];
  } else if ([self isKindOfClass:[UIView class]] ||
             [self respondsToSelector:@selector(accessibilityContainer)]) {
    return [GREYElementHierarchy hierarchyStringForElement:self];
  } else {
    GREYFatalAssertWithMessage(NO,
                               @"grey_recursiveDescription made on an element that is not a valid "
                               @"UI element: %@", self);
    return nil;
  }
}

- (UIView *)grey_viewContainingSelf {
  if ([self grey_isWebAccessibilityElement]) {
    return [[self grey_containersAssignableFromClass:[UIWebView class]] firstObject];
  } else if ([self isKindOfClass:[UIView class]]) {
    return [self grey_container];
  } else if ([self respondsToSelector:@selector(accessibilityContainer)]) {
    id container = [self grey_container];
    if (![container isKindOfClass:[UIView class]]) {
      return [container grey_viewContainingSelf];
    }
    return container;
  }
  return nil;
}

- (id)grey_container {
  if ([self isKindOfClass:[UIView class]]) {
    return [(UIView *)self superview];
  } else if ([self respondsToSelector:@selector(accessibilityContainer)]) {
    return [self performSelector:@selector(accessibilityContainer)];
  } else {
    return nil;
  }
}

- (NSArray *)grey_containersAssignableFromClass:(Class)klass {
  NSMutableArray *containers = [[NSMutableArray alloc] init];

  id container = self;
  do {
    container = [container grey_container];
    if ([container isKindOfClass:klass]) {
      [containers addObject:container];
    }
  } while (container);

  return containers;
}

/**
 *  @return @c YES if @c self is an accessibility element within a UIWebView, @c NO otherwise.
 */
- (BOOL)grey_isWebAccessibilityElement {
  return [self isKindOfClass:gWebAccessibilityWrapper];
}

- (CGPoint)grey_accessibilityActivationPointInWindowCoordinates {
  UIView *view =
      [self isKindOfClass:[UIView class]] ? (UIView *)self : [self grey_viewContainingSelf];
  GREYFatalAssertWithMessage(view,
                             @"Corresponding UIView could not be found for UI element %@", self);

  // Convert activation point from screen coordinates to window coordinates.
  if ([view isKindOfClass:[UIWindow class]]) {
    return [(UIWindow *)view convertPoint:self.accessibilityActivationPoint fromWindow:nil];
  } else {
    return [view.window convertPoint:self.accessibilityActivationPoint fromWindow:nil];
  }
}

- (CGPoint)grey_accessibilityActivationPointRelativeToFrame {
  CGRect axFrame = [self accessibilityFrame];
  CGPoint axPoint = [self accessibilityActivationPoint];
  return CGPointMake(axPoint.x - axFrame.origin.x, axPoint.y - axFrame.origin.y);
}

- (NSString *)grey_description {
  NSMutableString *description = [[NSMutableString alloc] init];

  // Class information.
  [description appendFormat:@"<%@", NSStringFromClass([self class])];
  [description appendFormat:@":%p", self];

  // IsAccessibilityElement.
  if ([self respondsToSelector:@selector(isAccessibilityElement)]) {
    [description appendFormat:@"; AX=%@", self.isAccessibilityElement ? @"Y" : @"N"];
  }

  // AccessibilityIdentifier from UIAccessibilityIdentification.
  if ([self respondsToSelector:@selector(accessibilityIdentifier)]) {
    NSString *value = [self performSelector:@selector(accessibilityIdentifier)];
    [description appendString:
        [self grey_formattedDescriptionOrEmptyStringForValue:value withPrefix:@"; AX.id="]];
  }

  // Include UIAccessibilityElement properties.

  // Accessibility Label.
  if ([self respondsToSelector:@selector(accessibilityLabel)]) {
    NSString *value = self.accessibilityLabel;
    [description appendString:
        [self grey_formattedDescriptionOrEmptyStringForValue:value withPrefix:@"; AX.label="]];
  }

  // Accessibility hint.
  if ([self respondsToSelector:@selector(accessibilityHint)]) {
    NSString *value = self.accessibilityHint;
    [description appendString:
        [self grey_formattedDescriptionOrEmptyStringForValue:value withPrefix:@"; AX.hint="]];
  }

  // Accessibility value.
  if ([self respondsToSelector:@selector(accessibilityValue)]) {
    NSString *value = self.accessibilityValue;
    [description appendString:
        [self grey_formattedDescriptionOrEmptyStringForValue:value withPrefix:@"; AX.value="]];
  }

  // Accessibility frame.
  if ([self respondsToSelector:@selector(accessibilityFrame)]) {
    [description appendFormat:@"; AX.frame=%@",
        NSStringFromCGRect(self.accessibilityFrame)];
  }

  // Accessibility activation point.
  if ([self respondsToSelector:@selector(accessibilityActivationPoint)]) {
    [description appendFormat:@"; AX.activationPoint=%@",
        NSStringFromCGPoint(self.accessibilityActivationPoint)];
  }

  // Accessibility traits.
  if ([self respondsToSelector:@selector(accessibilityTraits)]) {
    [description appendFormat:@"; AX.traits=\'%@\'",
        NSStringFromUIAccessibilityTraits(self.accessibilityTraits)];
  }

  // Accessibility element is focused from UIAccessibility.
  if ([self respondsToSelector:@selector(accessibilityElementIsFocused)]) {
    [description appendFormat:
        @"; AX.focused=\'%@\'", self.accessibilityElementIsFocused ? @"Y" : @"N"];
  }

  // Values present if view.
  if ([self isKindOfClass:[UIView class]]) {
    UIView *selfAsView = (UIView *)self;

    // View frame.
    [description appendFormat:@"; frame=%@", NSStringFromCGRect(selfAsView.frame)];

    // Visual properties.
    if (selfAsView.isOpaque) {
      [description appendString:@"; opaque"];
    }
    if (selfAsView.isHidden) {
      [description appendString:@"; hidden"];
    }

    [description appendFormat:@"; alpha=%g", selfAsView.alpha];

    if (!selfAsView.isUserInteractionEnabled) {
      [description appendString:@"; UIE=N"];
    }
  }

  // Check if control is enabled.
  if ([self isKindOfClass:[UIControl class]] && !((UIControl *)self).isEnabled) {
    [description appendString:@"; disabled"];
  }

  // Text used for presentation.
  if ([self respondsToSelector:@selector(text)]) {
    // The text method of private class UIWebDocumentView can throw an exception when calling its
    // text method while loading a web page.
    @try {
      NSString *text = [self performSelector:@selector(text)];
      [description appendFormat:@"; text=\'%@\'", !text ? @"" : text];
    } @catch (NSException *exception) {
      NSLog(@"Caught exception when calling text method on %@", [self class]);
    }
  }

  [description appendString:@">"];
  return description;
}

- (NSString *)grey_shortDescription {
  NSMutableString *description = [[NSMutableString alloc] init];

  [description appendString:NSStringFromClass([self class])];

  if ([self respondsToSelector:@selector(accessibilityIdentifier)]) {
    NSString *accessibilityIdentifier = [self performSelector:@selector(accessibilityIdentifier)];
    NSString *axIdentifierDescription =
        [self grey_formattedDescriptionOrEmptyStringForValue:accessibilityIdentifier
                                                  withPrefix:@"; AX.id="];
    [description appendString:axIdentifierDescription];
  }

  if ([self respondsToSelector:@selector(accessibilityLabel)]) {
    NSString *axLabelDescription =
        [self grey_formattedDescriptionOrEmptyStringForValue:self.accessibilityLabel
                                                  withPrefix:@"; AX.label="];
    [description appendString:axLabelDescription];
  }

  return description;
}

#pragma mark - Private

/**
 *  Returns an array containing @c target, @c selector and @c argumentOrNil combination. Always use
 *  this when adding an entry to the dictionary for consistent key hashing.
 *
 *  @param selector      Selector to be added to the array.
 *  @param argumentOrNil Argument to be added to the array.
 *
 *  @return Array containing @c target, @c selector and @c argumentOrNil combination.
 */
- (NSArray *)grey_arrayWithSelector:(SEL)selector argument:(id)argumentOrNil {
  return [NSArray arrayWithObjects:[NSValue valueWithPointer:selector], argumentOrNil, nil];
}

/**
 *  Takes a value string, which if non-empty, is returned with a prefix attached, else an empty
 *  string is returned.
 *
 *  @param value  The string representing a value.
 *  @param prefix The prefix to be attached to the value
 *
 *  @return @c prefix appended to the @c value or empty string if @c value is @c nil.
 */
- (NSString *)grey_formattedDescriptionOrEmptyStringForValue:(NSString *)value
                                                  withPrefix:(NSString *)prefix {
  NSMutableString *description = [[NSMutableString alloc] initWithString:@""];
  if (value.length > 0) {
    [description appendString:prefix];
    [description appendFormat:@"\'%@\'", value];
  }
  return description;
}

@end
