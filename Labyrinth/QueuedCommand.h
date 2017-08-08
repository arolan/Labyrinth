//
//  QueuedCommand.h
//  Labyrinth
//
//  Created by ROLAN MARAT on 8/7/17.
//  Copyright © 2017 Rolan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueuedCommand : NSObject

@property(nonatomic, strong) NSMutableDictionary *commandsDictionary;
@property(nonatomic, strong) NSString *roomId;

@end
