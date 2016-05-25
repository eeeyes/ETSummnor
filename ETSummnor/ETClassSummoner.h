//
//  ETClassSummoner.h
//  XIBConverter
//
//  Created by chaoran on 16/5/19.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface ETMethod : NSObject
@property (nonatomic,strong) NSString* methodEncode;
@property (nonatomic,strong) JSValue* jsFunc;
@end

@interface ETClass : NSObject

@property (nonatomic,strong) NSString* superClassName;

@property (nonatomic,strong) NSString* className;

@property (nonatomic,strong) NSDictionary* funcDict;

-(id)newObj;

@end

@interface ETClassSummoner : NSObject

-(ETClass*)registerClassNamed:(NSString*)className superClassName:(NSString*)superClassName funcDic:(NSDictionary*)funcDict;


@end
