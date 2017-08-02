//
//  RestHelper.m
//  Labyrinth
//
//  Created by ROLAN MARAT on 8/2/17.
//  Copyright © 2017 Rolan. All rights reserved.
//

#import "RestHelper.h"

NSString* const baseURL = @"http://challenge2.airtime.com:10001/";
NSString* const email = @"abcdef@gmail.com";

@implementation RestHelper

+ (void) getStartRoomId:(void(^)(NSInteger roomId, NSArray *drones))callback {
    NSString *urlString = [NSString stringWithFormat:@"%@/start", baseURL, nil];
    NSURL *urlForStart = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:urlForStart];
    [request setHTTPMethod:@"GET"];
    [request setValue:email forHTTPHeaderField:@"x-commander-email"];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"json: %@", json);
        if (callback) {
            if (json) {
                NSInteger rid = [json[@"roomId"] integerValue];
                NSArray *dronesArray = json[@"drones"];
                callback(rid, dronesArray);
            } else {
                callback(0, nil);
            }
            
        }
    }] resume];
}

+ (void) performCommands:(NSMutableDictionary *)commands droneId:(NSInteger)droneId callback:(void(^)(NSMutableDictionary *results))callback {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/drone/%li/commands", baseURL, (long)droneId, nil];
    NSURL *urlForStart = [NSURL URLWithString:urlString];
    
    NSString *post = [NSString stringWithFormat:@"test=Message&this=isNotReal"];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:urlForStart];
    [request setHTTPMethod:@"POST"];
    [request setValue:email forHTTPHeaderField:@"x-commander-email"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];

    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"json: %@", json);
        if (callback) {
            if (json) {
                NSInteger rid = [json[@"roomId"] integerValue];
                NSArray *dronesArray = json[@"drones"];
                callback(rid, dronesArray);
            } else {
                callback(0, nil);
            }
            
        }
    }] resume];
}

@end
