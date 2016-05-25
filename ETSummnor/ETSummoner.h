//
//  ETSummoner.h
//  XIBConverter
//
//  Created by chaoran on 16/5/17.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETSummoner : NSObject

+(id)callCFunction:(void*)functionPtr funcTypeEncode:(NSString*)funcTypeEncode arguments:(NSArray*)arguments;

+(id)callCVarFunction:(void*)functionPtr funcTypeEncode:(NSString*)functypeEncode fixedArgumentCount:(NSUInteger)fixedArgumentCount arguments:(NSArray*)arguments;

+(id)v2CallObjcFunction:(NSString*)selectorStr funcTypeEncode:(NSString*)functypeEncode arguments:(NSArray*)arguments;

+(id)callObjcSuperFunction:(NSString*)selectorStr funcTypeEncode:(NSString*)functypeEncode arguments:(NSArray*)arguments;

@end
