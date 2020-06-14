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

#import "Common/GREYAnalytics.h"

#import "Additions/NSString+GREYAdditions.h"
#import "Additions/NSURL+GREYAdditions.h"
#import "Common/GREYAnalyticsDelegate.h"
#import "Common/GREYConfiguration.h"
#import "Common/GREYLogger.h"

/**
 *  The Analytics tracking ID that receives EarlGrey usage data.
 */
static NSString *const kGREYAnalyticsTrackingID = @"UA-54227235-9";

/**
 *  The endpoint that receives EarlGrey usage data.
 */
static NSString *const kTrackingEndPoint = @"https://ssl.google-analytics.com/collect";

@interface GREYAnalytics() <GREYAnalyticsDelegate>
@end

@implementation GREYAnalytics {
  // Overridden GREYAnalytics delegate for custom handling of analytics.
  __weak id<GREYAnalyticsDelegate> _delegate;
  // Once set, analytics will be sent on next XCTestCase tearDown.
  BOOL _earlgreyWasCalledInXCTestContext;
}

+ (void)initialize {
  if (self == [GREYAnalytics class]) {
    NSString *analyticsRegEx = [NSString stringWithFormat:@".*%@.*", kGREYAnalyticsTrackingID];
    [NSURL grey_addBlacklistRegEx:analyticsRegEx];
  }
}

+ (instancetype)sharedInstance {
  static GREYAnalytics *sharedInstance = nil;
  static dispatch_once_t token = 0;
  dispatch_once(&token, ^{
    sharedInstance = [[GREYAnalytics alloc] initOnce];
  });
  return sharedInstance;
}

- (instancetype)initOnce {
  self = [super init];
  if (self) {
    _delegate = nil;
    _earlgreyWasCalledInXCTestContext = NO;
  }
  return self;
}

- (void)didInvokeEarlGrey {
  // Track only if EarlGrey is called in the context of a test case.
}

- (void)setDelegate:(id<GREYAnalyticsDelegate>)delegate {
  _delegate = delegate;
}

- (id<GREYAnalyticsDelegate>)delegate {
  // The default delegate is self.
  return _delegate ? _delegate : self;
}

/** Custom NSURLSession which uses fixed user agent. */
+ (NSURLSession *)analyticsURLSession {
  static dispatch_once_t onceToken;
  static NSURLSession *session;
  dispatch_once(&onceToken, ^{
    NSURLSessionConfiguration *configuration =
        [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{ @"User-Agent": @"EarlGrey" };
    session = [NSURLSession sessionWithConfiguration:configuration];
  });
  return session;
}

+ (void)sendEventHitWithTrackingID:(NSString *)trackingID
                          clientID:(NSString *)clientID
                          category:(NSString *)category
                            action:(NSString *)action
                             value:(NSString *)value {
  // Initialize the payload with version(=1), tracking ID, client ID, category, action, and value.
  NSMutableString *payload = [[NSMutableString alloc] initWithFormat:@"v=1"
                                                                     @"&t=event"
                                                                     @"&tid=%@"
                                                                     @"&cid=%@"
                                                                     @"&ec=%@"
                                                                     @"&ea=%@"
                                                                     @"&ev=%@",
                                                                     trackingID,
                                                                     clientID,
                                                                     category,
                                                                     action,
                                                                     value];

  NSURLComponents *components = [[NSURLComponents alloc] initWithString:kTrackingEndPoint];
  [components setQuery:payload];
  NSURL *url = [components URL];

  [[[self analyticsURLSession] dataTaskWithURL:url
                             completionHandler:^(NSData *data,
                                                 NSURLResponse *response,
                                                 NSError *error) {
                               if (error) {
                                 // Failed to send analytics data, but since the test might be
                                 // running in a sandboxed environment it's not a good idea to
                                 // freeze or throw assertions, let's just log and move on.
                                 GREYLogVerbose(@"Failed to send analytics data due to: %@", error);
                               }
                             }] resume];
}

#pragma mark - GREYAnalyticsDelegate

- (void)trackEventWithTrackingID:(NSString *)trackingID
                        clientID:(NSString *)clientID
                        category:(NSString *)category
                          action:(NSString *)action
                           value:(NSString *)value {
  [GREYAnalytics sendEventHitWithTrackingID:trackingID
                                   clientID:clientID
                                   category:category
                                     action:action
                                      value:value];
}

#pragma mark - Private

@end
