//
//  AppDelegate.h
//  HotelClendar
//
//  Created by 赵海明 on 2018/4/16.
//  Copyright © 2018年 cnmobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

