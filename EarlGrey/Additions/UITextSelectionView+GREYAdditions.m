//
//  UITextSelectionView.m
//  EarlGrey
//
//  Created by Xavier Jurado on 01/09/2020.
//  Copyright © 2020 Google Inc. All rights reserved.
//

#import "UITextSelectionView+GREYAdditions.h"

#include <objc/runtime.h>

#import "Common/GREYAppleInternals.h"
#import "GREYFatalAsserts.h"

@implementation UITextSelectionView_GREYAdditions

+ (void)load {
	if(@available(iOS 14.0, *))
	{
		SEL name = @selector(_setCaretBlinkAnimationEnabled:);
		Method m = class_getInstanceMethod(NSClassFromString(@"UITextSelectionView"), name);
		BOOL (*orig)(id self, SEL _cmd, BOOL enabled) = (void*)method_getImplementation(m);
		method_setImplementation(m, imp_implementationWithBlock(^ BOOL (id _self, BOOL enabled) {
			orig(_self, name, NO);
			return NO;
		}));
	}
}

@end
