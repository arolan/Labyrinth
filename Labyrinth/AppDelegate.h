//
//  AppDelegate.h
//  Labyrinth
//
//  Created by ROLAN MARAT on 8/2/17.
//  Copyright © 2017 Rolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

