//
//  GlobalObject.h
//  HybridApp
//
//  Created by Joseph Kang on 2017. 4. 7..
//  Copyright © 2017년 Joseph_iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalObject : NSObject

+ (GlobalObject *)sharedInstance;

@property (nonatomic, strong) NSString *tokenCheck1;
@property (nonatomic, strong) NSString *tokenCheck2;

@end
