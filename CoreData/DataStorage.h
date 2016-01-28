//
//  DataStorage.h
//  CoreData
//
//  Created by Thomson on 16/1/28.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SimpleModel;

@interface DataStorage : NSObject

- (NSManagedObjectContext *)privateThreadContext;

- (NSManagedObjectContext *)mainThreadContext;

- (SimpleModel *)modelWithUid:(NSString *)uid;

- (void)saveModelWithDictionary:(NSDictionary *)dictionary;

@end

extern NSString * const UserIdKey;
extern NSString * const AvatarKey;
extern NSString * const NicknameKey;
extern NSString * const SexKey;