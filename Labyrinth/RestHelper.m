//
//  RestHelper.m
//  Labyrinth
//
//  Created by ROLAN MARAT on 8/2/17.
//  Copyright © 2017 Rolan. All rights reserved.
//

#import "RestHelper.h"
#import "DroneCommand.h"
#import "AFNetworking.h"
#import "Drone.h"

NSString* const baseURL = @"http://challenge2.airtime.com:10001";
NSString* const email = @"abcdef@gmail.com";

@interface RestHelper()
@property(nonatomic, strong) AFHTTPSessionManager *manager;
@end

@implementation RestHelper

- (instancetype)init {
    if (self = [super init]) {
        self.manager = [AFHTTPSessionManager manager];
    }
    return self;
}

- (BOOL)inProgressCalls {
    return [self.manager.tasks count] > 0;
}

- (void) getStartRoomId:(void(^)(NSString *roomId, NSMutableArray *drones))callback {
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.manager.requestSerializer setValue:email forHTTPHeaderField:@"x-commander-email"];
    NSString *urlString = [NSString stringWithFormat:@"%@/start", baseURL, nil];
    [self.manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject) {
            NSDictionary *responseDict = (NSDictionary *)responseObject;
            
            NSString *rid = responseDict[@"roomId"];
            NSArray *dronesArray = responseDict[@"drones"];
            NSMutableArray *drones = [NSMutableArray array];
            for(NSString *drone in dronesArray) {
                Drone *d = [[Drone alloc] init];
                d.droneId = drone;
                d.isBusy = NO;
                [drones addObject:d];
            }
            callback(rid, drones);
        } else {
            callback(0, nil);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(0, nil);
    }];
}

- (void) performCommands:(NSMutableDictionary *)commands droneId:(NSString *)droneId callback:(void(^)(NSMutableDictionary *results))callback {
    NSString *urlString = [NSString stringWithFormat:@"%@/drone/%@/commands", baseURL, droneId, nil];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.manager.requestSerializer setValue:email forHTTPHeaderField:@"x-commander-email"];
    
    [self.manager POST:urlString parameters:commands progress:nil success:^(NSURLSessionDataTask *task, id  responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject) {
            callback(responseObject);
        } else {
            callback(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(nil);
    }];
}

- (void) reportWritings:(NSArray *)writings callback:(void(^)(BOOL result))callback {
    NSMutableString *finalWriting = [NSMutableString string];
    
    for (NSString *writing in writings) {
        [finalWriting appendString:writing];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/report", baseURL, nil];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.manager.requestSerializer setValue:email forHTTPHeaderField:@"x-commander-email"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"message"] = finalWriting;
    
    [self.manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id  responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if (responseObject) {
            callback(YES);
        } else {
            callback(NO);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(NO);
    }];
}

@end
