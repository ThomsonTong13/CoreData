//
//  DataStorage.m
//  CoreData
//
//  Created by Thomson on 16/1/28.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "DataStorage.h"
#import "SimpleModel.h"

NSString * const UserIdKey = @"com.thomson.uid";
NSString * const AvatarKey = @"com.thomson.avatar";
NSString * const NicknameKey = @"com.thomson.nickname";
NSString * const SexKey = @"com.thomson.sex";

@interface DataStorage ()
{
    NSPersistentStoreCoordinator    *_coordinator;

    NSManagedObjectContext          *_mainThreadContext;

    NSManagedObjectContext          *_rootContext;
}

@end

@implementation DataStorage

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        _rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

        _rootContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    }

    return self;
}

- (void)dealloc
{
    if (![NSThread mainThread]) return;

    if ([self.mainThreadContext hasChanges])
    {
        [self.mainThreadContext save:nil];

        [_rootContext performBlockAndWait:^{
            [_rootContext save:nil];
        }];
    }
}

- (void)saveContext
{
    [self.mainThreadContext save:nil];

    [_rootContext performBlock:^{
        [_rootContext save:nil];
    }];
}

#pragma mark - Public Methods

- (NSManagedObjectContext *)privateThreadContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    context.parentContext = self.mainThreadContext;

    return context;
}

- (SimpleModel *)modelWithUid:(NSString *)uid
{
    if (![NSThread isMainThread]) return nil;

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@", uid];

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([SimpleModel class])];
    fetchRequest.predicate = predicate;

    NSError *error = nil;

    NSArray *modelList = [self.mainThreadContext executeFetchRequest:fetchRequest error:&error];

    if (modelList)
    {
        SimpleModel *model = [modelList firstObject];

        return model;
    }

    return nil;
}

- (void)saveModelWithDictionary:(NSDictionary *)dictionary
{
    // 先查询是否存在
    SimpleModel *model = [self modelWithUid:dictionary[UserIdKey]];

    // 若不存在则创建`NSManagedObject`
    if (!model)
    {
        model = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SimpleModel class]) inManagedObjectContext:self.mainThreadContext];

        model.uid = dictionary[UserIdKey];
    }

    model.nickname = dictionary[NicknameKey];
    model.avatar = dictionary[AvatarKey];
    model.sex = dictionary[SexKey];

    [self saveContext];
}

#pragma mark - Private Methods

- (NSString *)momResource
{
    return NSStringFromClass([self class]);
}

- (NSManagedObjectModel *)objectModel
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    NSString *momPath = [bundle pathForResource:[self momResource] ofType:@"momd"];
    if(!momPath)
    {
        momPath = [bundle pathForResource:[self momResource] ofType:@"mom"];
    }

    return [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:momPath]];
}

- (NSString *)databaseFileName
{
    return @"CoreData.sqlite";
}

- (NSString *)persistentStoreDirectory
{
    NSString *relativePath = [[[self class] documentsPath] stringByAppendingString:@"/Database"];

    [[self class] prepareDirectory:relativePath];

    return relativePath;
}

+ (NSString *)documentsPath
{
    return [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
}

+ (BOOL)prepareDirectory:(NSString *)dir
{
    NSString *docPath = [DataStorage documentsPath];
    NSString *fullDirPath = [docPath stringByAppendingPathComponent:dir];

    NSRange docRange = [dir rangeOfString:docPath];
    if (docRange.location != NSNotFound)
    {
        fullDirPath = dir;
    }

    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:fullDirPath isDirectory:nil])
    {
        [fileManager createDirectoryAtPath:fullDirPath withIntermediateDirectories:YES attributes:nil error:&error];

        if (error)
        {
            return NO;
        }
    }

    return YES;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_coordinator) return _coordinator;

    NSManagedObjectModel *mom = [self objectModel];

    if (!mom) return nil;

    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];

    NSString *docsPath = [self persistentStoreDirectory];

    NSString *storePath = [docsPath stringByAppendingPathComponent:[self databaseFileName]];

    NSError         *error = nil;
    NSDictionary    *options = @{ NSMigratePersistentStoresAutomaticallyOption: @(YES),
                                  NSInferMappingModelAutomaticallyOption : @(YES) };
    NSURL           *storeURL = [NSURL fileURLWithPath:storePath];

    if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                    configuration:nil
                                              URL:storeURL
                                          options:options
                                            error:&error])
    {
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

        if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:nil
                                                  URL:storeURL
                                              options:options
                                                error:&error])
        {
            [_coordinator addPersistentStoreWithType:NSInMemoryStoreType
                                       configuration:nil
                                                 URL:storeURL
                                             options:nil
                                               error:&error];
        }
    }

    return _coordinator;
}

- (NSManagedObjectContext *)mainThreadContext
{
    if (_mainThreadContext) return _mainThreadContext;

    _mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

    _mainThreadContext.parentContext = _rootContext;

    return _mainThreadContext;
}

@end
