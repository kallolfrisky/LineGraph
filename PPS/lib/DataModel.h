//
//  DataModel.h
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//


// The main data model object
@interface DataModel : NSObject

+ (DataModel*)sharedInstance;

- (NSString*)myUUID;
- (NSString*)deviceToken;
- (NSString*)userId;

- (void)setUserId:(NSString*)userId;
- (void)setDeviceToken:(NSString*)token;

- (BOOL)validateEmail:(NSString *) candidate;
- (BOOL)validateUrl: (NSString *) candidate;

- (int)getDaysBetween:(NSDate *)dt1 and:(NSDate *)dt2;
- (NSString*)getDaysSinceToday:(NSDate *)dt1;

- (NSString*)getDelphiTimeStamp:(NSDate *)startDate;
- (NSTimeInterval)convertDelphiTimeStampToiOSTimeStamp:(NSString *)delphiTimeStamp;

@end
