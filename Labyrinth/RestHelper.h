//
//  RestHelper.h
//  Labyrinth
//
//  Created by ROLAN MARAT on 8/2/17.
//  Copyright © 2017 Rolan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestHelper : NSObject

- (void) getStartRoomId:(void(^)(NSString *roomId, NSMutableArray *drones))callback;
- (void) performCommands:(NSMutableDictionary *)commands droneId:(NSString *)droneId callback:(void(^)(NSMutableDictionary *results))callback;
- (void) reportWritings:(NSArray *)writings callback:(void(^)(BOOL result))callback;
- (BOOL)inProgressCalls;

@end
