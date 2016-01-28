//
//  SimpleModel+CoreDataProperties.h
//  CoreData
//
//  Created by Thomson on 16/1/28.
//  Copyright © 2016年 Thomson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SimpleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SimpleModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *avatar;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *nickname;
@property (nullable, nonatomic, retain) NSNumber *sex;

@end

NS_ASSUME_NONNULL_END
