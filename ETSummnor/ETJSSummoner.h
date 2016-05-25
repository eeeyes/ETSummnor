//
//  ETJSSummoner.h
//  XIBConverter
//
//  Created by chaoran on 16/5/18.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class JRPointer;

@interface ETJSSummoner : NSObject

+(JSContext*)initJSContext;

+(JRPointer*)packValues:(NSArray*)arguments typeEncode:(NSString*)typeEncode;

+(id)unPackValue:(JRPointer*)value  atIndex:(NSUInteger)idx;

@end
