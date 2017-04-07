//
//  GlobalObject.m
//  HybridApp
//
//  Created by Joseph Kang on 2017. 4. 7..
//  Copyright © 2017년 Joseph_iMac. All rights reserved.
//

#import "GlobalObject.h"

@implementation GlobalObject

+ (GlobalObject *)sharedInstance
{
    static GlobalObject *sharedInstance;
    
    @synchronized(self) {
        if(!sharedInstance) {
            sharedInstance = [[GlobalObject alloc] init];
        }
    }
    
    return sharedInstance;
}

- (id)init
{
    NSLog(@"%s", __FUNCTION__);
    
    self = [super init];
    if (self) {
        _tokenCheck1 = @"";
        _tokenCheck2 = @"";
    }
    
    return self;
}

@end
