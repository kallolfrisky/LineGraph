//
//  DataModel.m
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "DataModel.h"

// We store our settings in the NSUserDefaults dictionary using these keys
static NSString* const DeviceTokenKey = @"DeviceToken";
static NSString* const UserId = @"UserId";
static NSString* const MyUUID = @"MyUUID";

@implementation DataModel

+ (void)initialize
{
	if (self == [DataModel class])
	{
		// Register default values for our settings
		[[NSUserDefaults standardUserDefaults] registerDefaults:
			@{  DeviceTokenKey: @"",
                MyUUID:@"",
                UserId:@""}];
	}
}

+ (DataModel*)sharedInstance {
    static dispatch_once_t once;
    static DataModel *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[DataModel alloc] init]; });
    return sharedInstance;
}

- (NSString*)myUUID
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:UserId];
    if (userId == nil || userId.length == 0) {
        userId = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:UserId];
    }
    return userId;
}

- (NSString*)deviceToken
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:DeviceTokenKey];
}

- (void)setDeviceToken:(NSString*)token
{
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:DeviceTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)userId
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:UserId];
}

- (void)setUserId:(NSString*)userId
{
	[[NSUserDefaults standardUserDefaults] setObject:userId forKey:UserId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) validateEmail: (NSString *) candidate {            //Email verification of RFC 2822
    
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

- (BOOL) validateUrl: (NSString *) candidate {
//    NSString *urlRegEx =
//    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
//    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
//    return [urlTest evaluateWithObject:candidate];

    NSURL *candidateURL = [NSURL URLWithString:candidate];
    if ([candidate length]) {
        if (!candidateURL.scheme.length) {
            candidateURL = [NSURL URLWithString:[@"http://" stringByAppendingString:candidate]];
        }
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:candidateURL];
    
    return [NSURLConnection canHandleRequest:request];
}

- (int)getDaysBetween:(NSDate *)dt1 and:(NSDate *)dt2{
   
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return (int)[components day]+1;
}

- (NSString*)getDaysSinceToday:(NSDate *)dt1{

    int days = [self getDaysBetween:dt1 and:[NSDate date]];
    return [NSString stringWithFormat:@"%d",days];
}

- (NSString*)getDelphiTimeStamp:(NSDate *)endDate{
    
    NSString *start = @"0001-01-01";

    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
    NSTimeInterval gmtTimeInterval = [endDate timeIntervalSinceReferenceDate] - timeZoneOffset;
    NSDate *gmtDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [dateFormatter dateFromString:start];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:gmtDate
                                                         options:NSCalendarWrapComponents];
    NSInteger days = [components day] + 1;
//    NSLog(@"%ld", days);
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    NSString *times = [timeFormatter stringFromDate:gmtDate];
    NSArray *timeSegments = [times componentsSeparatedByString:@":"];
    NSInteger miliSeconds = ((((([timeSegments[0] intValue] * 60) + [timeSegments[1] intValue]) * 60) + [timeSegments[2] intValue]) * 1000);
    
    NSString *delphiTimeStamp = [NSString stringWithFormat:@"%ld.%ld",(long)days,(long)miliSeconds];
//    NSLog(@"delphiTimeStamp: %@",delphiTimeStamp);
    
    return delphiTimeStamp;
}

- (NSTimeInterval)convertDelphiTimeStampToiOSTimeStamp:(NSString *)delphiTimeStamp{

    if (delphiTimeStamp.length == 0) return 0;
    
    NSTimeInterval timeStamp;
    NSUInteger days = [[delphiTimeStamp componentsSeparatedByString:@"."][0] integerValue];
    NSUInteger times = [[delphiTimeStamp componentsSeparatedByString:@"."][1] integerValue];
    
    timeStamp = ((days - 719163)*86400) + (times/1000);
//    NSLog(@"timeStamp: %f",timeStamp);
    
    return timeStamp;
}

@end
