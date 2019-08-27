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

#import "Additions/UIScrollView+GREYAdditions.h"

#include <objc/message.h>
#include <objc/runtime.h>

#import "Common/GREYAppleInternals.h"
#import "Common/GREYFatalAsserts.h"
#import "Common/GREYSwizzler.h"

@implementation UIScrollView (GREYAdditions)

- (BOOL)grey_hasScrollResistance {
  if (self.bounces) {
    return ((BOOL (*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"_isBouncing"));
  } else {
    // NOTE that these values are not reliable as scroll views without bounce have non-zero
    // velocities even when they are at the edge of the content and cannot be scrolled.
    double horizontalVelocity =
        ((double (*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"_horizontalVelocity"));
    double verticalVelocity =
        ((double (*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"_verticalVelocity"));
    return horizontalVelocity == 0 && verticalVelocity == 0;
  }
}

@end
