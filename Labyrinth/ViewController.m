//
//  ViewController.m
//  Labyrinth
//
//  Created by ROLAN MARAT on 8/2/17.
//  Copyright © 2017 Rolan. All rights reserved.
//

#import "ViewController.h"
#import "RestHelper.h"
#import "Drone.h"
#import "QueuedCommand.h"

@interface ViewController ()
@property(nonatomic, strong) NSArray *drones;
@property(nonatomic, strong) NSMutableDictionary *writings;
@property(nonatomic, strong) NSMutableSet *visitedRooms;
@property(nonatomic, strong) NSMutableArray *queue;
@property(nonatomic, strong) RestHelper *restHelper;
@property(nonatomic) NSInteger commandId;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.writings = [NSMutableDictionary dictionary];
    self.visitedRooms = [NSMutableSet set];
    self.queue = [NSMutableArray array];
    self.restHelper = [[RestHelper alloc] init];
    [self findWritingsInLabyrinth];
}

- (void)findWritingsInLabyrinth {
    [self.restHelper getStartRoomId:^(NSString *roomId, NSMutableArray *drones) {
        self.drones = drones;
        if ([self.drones count]) {
            NSMutableDictionary *commandDictionary = [NSMutableDictionary dictionary];
            //    NSString *commandId = [NSString stringWithFormat:@"%@%i", droneId, commandCounter, nil];
            commandDictionary[[self generateCommandId]] = @{@"explore" : roomId};
            commandDictionary[[self generateCommandId]] = @{@"read" : roomId};
            Drone *d = [self getNextAvailableDrone];
            if (d) {
                [self.visitedRooms addObject:roomId];
                [self exploreLabyrinth:commandDictionary drone:d];
            } else {
                NSLog(@"Error. All drones are busy right away from the start.");
            }
            
        } else {
            NSLog(@"No drones available for exploration. Exiting.");
        }
        
    }];
}

- (Drone *)getNextAvailableDrone {
    for (Drone *d in self.drones) {
        if (!d.isBusy) {
            return d;
        }
    }
    return nil;
}

- (NSString *)generateCommandId {
    return [NSString stringWithFormat:@"c%li",(long)self.commandId++];
}
- (void)exploreLabyrinth:(NSMutableDictionary *)commandDictionary drone:(Drone *)drone {
    drone.isBusy = YES;
    
    [self.restHelper performCommands:commandDictionary droneId:drone.droneId callback:^(NSMutableDictionary *results) {
        drone.isBusy = NO;
        
//        NSLog(@"drone command results = %@", results);
        
        for(NSString *key in results) {
            NSDictionary *commandResultsDict = results[key];
            if(commandResultsDict[@"connections"]) {
                NSArray *connections = commandResultsDict[@"connections"];
                for (NSString *connectedRoom in connections) {
                    if (![self.visitedRooms containsObject:connectedRoom]) {
                        NSMutableDictionary *nextCommands = [NSMutableDictionary dictionary];
                        nextCommands[[self generateCommandId]] = @{@"explore" : connectedRoom};
                        QueuedCommand *qc = [[QueuedCommand alloc] init];
                        qc.commandsDictionary = nextCommands;
                        qc.roomId = connectedRoom;
                        [self.queue addObject:qc];
                        
                        nextCommands = [NSMutableDictionary dictionary];
                        nextCommands[[self generateCommandId]] = @{@"read" : connectedRoom};
                        qc = [[QueuedCommand alloc] init];
                        qc.commandsDictionary = nextCommands;
                        qc.roomId = connectedRoom;
                        [self.queue addObject:qc];
                    }
                }
            } else if(commandResultsDict[@"order"]) {
                NSString *order = commandResultsDict[@"order"];
//                NSLog(@"order = %@", order);
                //writing is valid, add it to our storage to keep track of it
                if ([order intValue] != -1) {
                    NSString *writing = commandResultsDict[@"writing"];
                    if (![self.writings objectForKey:writing]) {
                        self.writings[writing] = order;
                    }
                }
            }
        }
        
        //the first available drone comes back, we need to schedule more explorations...
        //modified BFS traversal taking into account queued commands and drone availability
        if ([self.queue count]) {
            Drone *d = [self getNextAvailableDrone];
            int i = 0;
            NSMutableDictionary *cummulativeDict = [NSMutableDictionary dictionary];
            
            while(d && [self.queue count]) {
                QueuedCommand *qc = [self.queue firstObject];
                [self.queue removeObject:qc];
                [self.visitedRooms addObject:qc.roomId];
                
                if (i < 5) {
                    [cummulativeDict addEntriesFromDictionary:qc.commandsDictionary];
                    i++;
                }
                //we got 5 commands to handle OR
                //less than 5 commands, but no more in the queue, then we should execute what's there
                if (i == 5 || ([self.queue count] == 0 && [[cummulativeDict allKeys] count] > 0)) {
                    i = 0;
                    [self exploreLabyrinth:cummulativeDict drone:d];
                    [cummulativeDict removeAllObjects];
                    d = [self getNextAvailableDrone];
                }
            }
        }
        
//        NSLog(@"queue = %lu", (unsigned long)[self.queue count]);
        
        if([self.queue count] == 0 && [self.restHelper inProgressCalls] == NO) {
            
            NSArray *sortedWritings = [self.writings keysSortedByValueUsingComparator:^NSComparisonResult(id  obj1, id  obj2) {
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return NSOrderedDescending;
                } else if ([obj1 integerValue] < [obj2 integerValue]) {
                    return NSOrderedAscending;
                }
                return NSOrderedSame;
            }];
            
            NSLog(@"going to report completed writings: = %@", sortedWritings);
            [self.restHelper reportWritings:sortedWritings callback:^(BOOL result) {
                if (result) {
                    NSLog(@"Successfully reported string from labyrinth.");
                } else {
                    NSLog(@"Failed to report string from labyrinth.");
                }
                
            }];
        }
    }];
}

@end
