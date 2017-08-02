//
//  RestHelper.h
//  Labyrinth
//
//  Created by ROLAN MARAT on 8/2/17.
//  Copyright © 2017 Rolan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestHelper : NSObject
+ (void) getStartRoomId:(void(^)(NSInteger roomId, NSArray *drones))callback;
+ (void) performCommands:(NSMutableDictionary *)commands droneId:(NSInteger)droneId callback:(void(^)(NSMutableDictionary *results))callback;

@end
