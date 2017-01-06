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

import EarlGrey
import Foundation

open func GREYAssert(_ expression: @autoclosure () -> Bool, reason: String) {
  GREYAssert(expression, reason, details: "Expected expression to be true")
}

open func GREYAssertTrue(_ expression: @autoclosure () -> Bool, reason: String) {
  GREYAssert(expression(), reason, details: "Expected the boolean expression to be true")
}

open func GREYAssertFalse(_ expression: @autoclosure () -> Bool, reason: String) {
  GREYAssert(!expression(), reason, details: "Expected the boolean expression to be false")
}

open func GREYAssertNotNil(_ expression: @autoclosure ()-> Any?, reason: String) {
  GREYAssert(expression() != nil, reason, details: "Expected expression to be not nil")
}

open func GREYAssertNil(_ expression: @autoclosure () -> Any?, reason: String) {
  GREYAssert(expression() == nil, reason, details: "Expected expression to be nil")
}

open func GREYAssertEqual(_ left: @autoclosure () -> AnyObject?,
                            _ right: @autoclosure () -> AnyObject?, reason: String) {
  GREYAssert(left() === right(), reason, details: "Expected left term to be equal to right term")
}

open func GREYAssertNotEqual(_ left: @autoclosure () -> AnyObject?,
                               _ right: @autoclosure () -> AnyObject?, reason: String) {
  GREYAssert(left() !== right(), reason, details: "Expected left term to not equal the right term")
}

open func GREYAssertEqualObjects<T: Equatable>( _ left: @autoclosure () -> T?,
                                                  _ right: @autoclosure () -> T?, reason: String) {
  GREYAssert(left() == right(), reason, details: "Expected object of the left term to be equal" +
    " to the object of the right term")
}

open func GREYAssertNotEqualObjects<T: Equatable>( _ left: @autoclosure () -> T?,
                                      _ right: @autoclosure () -> T?, reason: String) {
  GREYAssert(left() != right(), reason, details: "Expected object of the left term to not" +
    " equal the object of the right term")
}

open func GREYFail(_ reason: String) {
  EarlGrey.handle(exception: GREYFrameworkException(name: kGREYAssertionFailedException,
                                                    reason: reason),
                  details: "")
}

open func GREYFailWithDetails(_ reason: String, details: String) {
  EarlGrey.handle(exception: GREYFrameworkException(name: kGREYAssertionFailedException,
                                                    reason: reason),
                  details: details)
}

private func GREYAssert(_ expression: @autoclosure () -> Bool,
                        _ reason: String, details: String) {
  GREYSetCurrentAsFailable()
  if !expression() {
    EarlGrey.handle(exception: GREYFrameworkException(name: kGREYAssertionFailedException,
                                                      reason: reason),
                    details: details)
  }
}

private func GREYSetCurrentAsFailable() {
  let greyFailureHandlerSelector =
    #selector(GREYFailureHandler.setInvocationFile(_:andInvocationLine:))
  let greyFailureHandler =
    Thread.current.threadDictionary.value(forKey: kGREYFailureHandlerKey) as! GREYFailureHandler
  if greyFailureHandler.responds(to: greyFailureHandlerSelector) {
    greyFailureHandler.setInvocationFile!(#file, andInvocationLine:#line)
  }
}

class EarlGrey: NSObject {
  open class func select(elementWithMatcher matcher:GREYMatcher,
                           file: String = #file,
                           line: UInt = #line) -> GREYElementInteraction {
    return EarlGreyImpl.invoked(fromFile: file, lineNumber: line).selectElement(with: matcher)
  }

  open class func setFailureHandler(handler: GREYFailureHandler,
                                      file: String = #file,
                                      line: UInt = #line) {
    return EarlGreyImpl.invoked(fromFile: file, lineNumber: line).setFailureHandler(handler)
  }

  open class func handle(exception: GREYFrameworkException,
                           details: String,
                           file: String = #file,
                           line: UInt = #line) {
    return EarlGreyImpl.invoked(fromFile: file, lineNumber: line).handle(exception,
                                                                           details: details)
  }

  @discardableResult open class func rotateDeviceTo(orientation: UIDeviceOrientation,
                                                      errorOrNil: UnsafeMutablePointer<NSError?>!,
                                                      file: String = #file,
                                                      line: UInt = #line)
    -> Bool {
    return EarlGreyImpl.invoked(fromFile: file, lineNumber: line)
      .rotateDevice(to: orientation,
                    errorOrNil: errorOrNil)
  }
}

extension GREYInteraction {
  @discardableResult open func assert(_ matcher: @autoclosure () -> GREYMatcher) -> Self {
    return self.assert(with:matcher())
  }

  @discardableResult open func assert(_ matcher: @autoclosure () -> GREYMatcher,
                                        error:UnsafeMutablePointer<NSError?>!) -> Self {
    return self.assert(with: matcher(), error: error)
  }


  @discardableResult open func using(searchAction: GREYAction,
                                       onElementWithMatcher matcher: GREYMatcher) -> Self {
    return self.usingSearch(searchAction, onElementWith: matcher)
  }
}
