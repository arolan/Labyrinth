//
//  Drone.h
//  Labyrinth
//
//  Created by ROLAN MARAT on 8/6/17.
//  Copyright © 2017 Rolan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Drone : NSObject

@property(nonatomic, strong) NSString *droneId;
@property(atomic) BOOL isBusy;

@end
