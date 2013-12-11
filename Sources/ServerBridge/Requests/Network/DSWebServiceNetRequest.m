#pragma mark - include
#import "DSWebServiceNetRequest.h"
#import "DSWebServiceParam.h"
#import "DSWebServiceURL.h"
#import "DSWebServiceResponse.h"
#import "NSData+OAdditions.h"

#define DEFAULT_TIMEOUT 30

#pragma mark - props
@interface DSWebServiceNetRequest ()
{
  long long _expectedDownloadSize;
}

@property (nonatomic, retain) DSWebServiceURL *url;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *responseData;


@end

#pragma mark - private
@interface DSWebServiceNetRequest (Private)
@end

@implementation DSWebServiceNetRequest
@synthesize url = _url;
@synthesize userInfo = _userInfo;
@synthesize params = _params;
@synthesize connection = _connection;
@synthesize delegate = _delegate;
@synthesize timeoutInterval = _timeoutInterval;
@synthesize responseData = _responseData;
@synthesize POSTData = _POSTData;
@synthesize POSTDataPath = _POSTDataPath;
@synthesize POSTDataKey = _POSTDataKey;
@synthesize POSTDataFileName = _POSTDataFileName;
@synthesize sendRawPOSTData = _sendRawPOSTData;

#pragma mark - init
- (id)initWithServer:(DSWebServiceURL *)theWebServiceURL
              params:(id<DSWebServiceParam>)theParams
            userInfo:(NSMutableDictionary *)theUserInfo
{
  self = [super init];

  if (self) {
    [self setUrl:theWebServiceURL];
    [self setParams:theParams];

    if ([theUserInfo isKindOfClass:[NSMutableDictionary class]] == NO) {
      _userInfo = [theUserInfo mutableCopy];
    }
    else {
      _userInfo = theUserInfo;
    }

    if (_userInfo == nil) {
      _userInfo = [NSMutableDictionary dictionary];
    }

    [self setTimeoutInterval:DEFAULT_TIMEOUT];
    _responseData = [[NSMutableData alloc] init];
  }

  return self;
}

- (id)initWithServer:(DSWebServiceURL *)theWebServiceURL
              params:(id<DSWebServiceParam>)theParams
{
  return [self initWithServer:theWebServiceURL
                       params:theParams
                     userInfo:nil];
}

+ (id)requestWithServer:(DSWebServiceURL *)theWebServiceURL
                 params:(id<DSWebServiceParam>)theParams
               userInfo:(NSMutableDictionary *)theUserInfo
{
  DSWebServiceNetRequest *request
    = [[DSWebServiceNetRequest alloc] initWithServer:theWebServiceURL
                                              params:theParams
                                            userInfo:theUserInfo];
  return request;
}

+ (id)requestWithServer:(DSWebServiceURL *)theWebServiceURL
                 params:(id<DSWebServiceParam>)theParams
{
  DSWebServiceNetRequest *request
    = [[DSWebServiceNetRequest alloc] initWithServer:theWebServiceURL
                                              params:theParams];
  return request;
}

- (void)setUserInfo:(NSMutableDictionary *)userInfo
{
  if (userInfo != _userInfo) {
    if ([userInfo isKindOfClass:[NSMutableDictionary class]] == NO) {
      _userInfo = [userInfo mutableCopy];
    }
    else {
      _userInfo = userInfo;
    }
  }
}

- (NSMutableDictionary *)userInfo
{
  if (!_userInfo) {
    _userInfo = [NSMutableDictionary dictionary];
  }

  return _userInfo;
}

#pragma mark - public
- (NSMutableData *)postDataForRequest:(NSMutableURLRequest *)request
{
  NSString *boundary
    = @"----WebKitFormBoundaryYA9vSekClgZaHxyb";

  NSString *contentType
    = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];

  [request addValue:contentType
 forHTTPHeaderField:@"Content-Type"];

  NSString *boundaryString
    = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];

  NSString *boundaryStringFinal
    = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];

  NSMutableData *postData = [NSMutableData data];

  [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];

  NSString *formDataHeader = nil;

  if ([self POSTDataFileName]) {
    if ([self POSTDataKey]) {
      formDataHeader
        = [NSString stringWithFormat:
                      @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n",
                      [self POSTDataKey], [self POSTDataFileName]];
    }
    else {
      formDataHeader
        = [NSString stringWithFormat:
                      @"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n",
                      [self POSTDataFileName]];
    }
  }
  else if ([self POSTDataKey]) {
    formDataHeader = [NSString stringWithFormat:
                                 @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
                                 [self POSTDataKey]];
  }
  else {
    formDataHeader
      = [NSString stringWithFormat:
                    @"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n",
                    @"POST.dat"];
  }

  [postData appendData:
              [formDataHeader dataUsingEncoding:NSUTF8StringEncoding]];

  NSData *mainPostData = nil;

  if ([self POSTData]) {
    mainPostData = [self POSTData];
  }
  else if ([self POSTDataPath]) {
    mainPostData = [NSData dataWithContentsOfMappedFile:[self POSTDataPath]];
  }

  [postData appendData:mainPostData];
  [postData appendData:
              [boundaryStringFinal dataUsingEncoding:NSUTF8StringEncoding]];
  return postData;
}

- (void)send
{
  [self start];
}

- (void)operationDidStart
{
  [super operationDidStart];

  [self setResponseData:[NSMutableData data]];
  [[self url] applyParams:_params];

  if ([[self url] HTTPMethod] == DSWebServiceURLHTTPMethodPOST &&
    [self POSTData] == nil) {
    [self setPOSTData:[[self url] paramsDataForPOST]];
  }
  NSString *urlString = [[self url] urlString];

  NSURL *nsURL = [NSURL URLWithString:urlString];

  NSMutableURLRequest *request = nil;

  if ([self POSTData] == nil && [self POSTDataPath] == nil) {
    request
      = [NSMutableURLRequest requestWithURL:nsURL
                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                            timeoutInterval:_timeoutInterval];
  }
  else {
    request = [[NSMutableURLRequest alloc] init];

    [request setURL:nsURL];

    NSData *postData = nil;
    if ([self sendRawPOSTData] == YES) {
      postData = [self POSTData];
    }
    else {
      postData = [self postDataForRequest:request];
    }

    // setting the body of the post to the request
    [request setHTTPBody:postData];

    NSString *dataLength
      = [NSString stringWithFormat:@"%d", [postData length]];

    [request addValue:dataLength
   forHTTPHeaderField:@"Content-Length"];

    [request setTimeoutInterval:DEFAULT_TIMEOUT];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
  }

  [request setHTTPMethod:
             NSStringFromDSWebServiceURLHTTPMethod([[self url] HTTPMethod])];

#ifdef DEBUG
  NSString *logString = nil;

  if ([[self url] HTTPMethod] == DSWebServiceURLHTTPMethodPOST) {
    NSString *POSTBodyString = [[NSString alloc] initWithData:[request HTTPBody]
                                          encoding:NSUTF8StringEncoding];
    logString = [NSString stringWithFormat:@"\nURL:\t%@\nHTTPBody: %@",
                                           urlString, POSTBodyString];
  }
  else {
    logString = [NSString stringWithFormat:@"\nURL:\t%@", urlString];
  }

  if (logString) {
    NSLog(@"%@", logString);
  }
#endif


  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                delegate:self
                                                        startImmediately:NO];
  [self setConnection:connection];
  for (NSString *mode in self.actualRunLoopModes) {
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                     forMode:mode];
  }

#if DEBUG_COOKIES
  NSArray *allCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
  for (NSHTTPCookie *c in allCookies) {
    NSString *cc = [[c value] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Cookie Value: %@\nFull Dumb:%@", cc, c);
  }
#endif
  
  [self.connection start];
}

- (void)operationWillFinish
{
  [super operationWillFinish];

  [[self connection] cancel];
  [self setConnection:nil];
}

- (void)finishWithError:(NSError *)error
{
  [super finishWithError:error];
}


- (DSWebServiceResponse *)response
{
  DSWebServiceResponse *response = [DSWebServiceResponse responseWithData:[self responseData]];

  return response;
}

- (BOOL)isRequestWithFunctionName:(NSString *)theFunctionName
                       HTTPMethod:(DSWebServiceURLHTTPMethod)theHTTPMethod
{
  return ([[[self url] functionName] isEqualToString:theFunctionName] &&
    [[self url] HTTPMethod] == theHTTPMethod);
}

- (NSString *)functionName
{
  return [[self url] functionName];
}

#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
  _expectedDownloadSize = [response expectedContentLength];

  if ([[self delegate]
             respondsToSelector:
               @selector(webServiceRequest:didReceiveResponseWithExpectedDownloadSize:)]) {
    [[self delegate]     webServiceRequest:self
didReceiveResponseWithExpectedDownloadSize:_expectedDownloadSize];
  }
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
  [[self responseData] appendData:data];
}

- (void)connection:(NSURLConnection *)conn
  didFailWithError:(NSError *)error
{
  NSLog(@"Connection error code: {%i}\nDescription: {%@}",
  [error code], [error localizedDescription]);

  [self setResponseData:nil];
  [self setConnection:nil];

  if ([[self delegate] respondsToSelector:
    @selector(webServiceRequest:didFailWithError:)]) {
    [[self delegate] webServiceRequest:self
                      didFailWithError:error];
  }

  [self finishWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSString *responseString
    = [[NSString alloc]
                 initWithData:[self responseData]
                 encoding:NSStringEncodingConversionExternalRepresentation];

  DSWebServiceResponse *webServiceResponse = [self response];
  BOOL parseSucceed = [webServiceResponse parse];

  if (responseString) {
    NSData *data = [self responseData];
    if (parseSucceed == NO) {
      data = [data truncatedDataToLength:MAX_RAW_DATA_BYTES_LOG];
    }

    NSLog(@"\nURL: %@\nParams: %@\nServer Response: %@",
              [self url],
              [self params],
              [[NSString alloc] initWithData:data
                                    encoding:NSStringEncodingConversionExternalRepresentation]);
  }

  if ([[self delegate] respondsToSelector:
    @selector(webServiceRequest:didEndLoadWithResponse:)]) {
    [[self delegate] webServiceRequest:self
                didEndLoadWithResponse:webServiceResponse];
  }

  [self setConnection:nil];

  [self finishWithError:nil];
}

#pragma mark - HTTPS workaround
- (BOOL)                   connection:(NSURLConnection *)connection
canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
  return [protectionSpace.authenticationMethod
    isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)               connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
  NSURLCredential *credentials = [NSURLCredential credentialForTrust:
                                                    [[challenge protectionSpace]
                                                                serverTrust]];
  [[challenge sender] useCredential:credentials
         forAuthenticationChallenge:challenge];

  [[challenge sender]
              continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#pragma mark - request userinfo
- (NSString *)description
{
  NSString *result = [[self params] description];
  return result;
}


//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder
{
  [encoder encodeBool:self.sendRawPOSTData forKey:@"sendRawPOSTData"];
  [encoder encodeObject:self.responseData forKey:@"responseData"];
  [encoder encodeObject:self.userInfo forKey:@"userInfo"];
  [encoder encodeObject:self.POSTData forKey:@"POSTData"];
  [encoder encodeObject:self.POSTDataPath forKey:@"POSTDataPath"];
  [encoder encodeObject:self.POSTDataKey forKey:@"POSTDataKey"];
  [encoder encodeObject:self.POSTDataFileName forKey:@"POSTDataFileName"];
  [encoder encodeDouble:self.timeoutInterval forKey:@"timeoutInterval"];
  [encoder encodeObject:self.url forKey:@"url"];
  [encoder encodeObject:self.params forKey:@"params"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
  self = [super init];
  if (self) {
    self.sendRawPOSTData = [decoder decodeBoolForKey:@"sendRawPOSTData"];
    self.responseData = [decoder decodeObjectForKey:@"responseData"];
    self.userInfo = [decoder decodeObjectForKey:@"userInfo"];
    self.POSTData = [decoder decodeObjectForKey:@"POSTData"];
    self.POSTDataPath = [decoder decodeObjectForKey:@"POSTDataPath"];
    self.POSTDataKey = [decoder decodeObjectForKey:@"POSTDataKey"];
    self.POSTDataFileName = [decoder decodeObjectForKey:@"POSTDataFileName"];
    [self setTimeoutInterval:[decoder decodeDoubleForKey:@"timeoutInterval"]];
    self.url = [decoder decodeObjectForKey:@"url"];
    self.params = [decoder decodeObjectForKey:@"params"];
  }
  return self;
}
@end
