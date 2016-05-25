//
//  JSRunner.h
//  XIBConverter
//
//  Created by chaoran on 16/5/8.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <JavaScriptCore/JavaScriptCore.h>



@protocol JRPointerJSExport <JSExport>

-(NSString*)description;

@end

@interface JRValue : NSObject

@property (nonatomic,assign) size_t size;

@property (nonatomic,strong) NSValue* value;

@end

@interface JRPointer : NSObject<JRPointerJSExport>

@property (nonatomic,strong) id obj;

@property (nonatomic,assign) void* ptr;

@property (nonatomic,assign) BOOL isBlock;

+(instancetype)JRPointerWithObj:(id)obj;

+(instancetype)JRPointerWithNSValue:(NSValue*)value;

@end



@interface JSRunner : NSObject

@property (nonatomic,readonly) JSContext* sharedContext;

-(void)registerJSFunction:(NSString*)jsContent forName:(NSString*)funcName;

-(void)executeJSFunction:(NSString*)name withArguments:(NSArray*)arguments;

+(JRPointer*)getValueFromStruct:(NSString*)objcTypeEncode value:(JRPointer*)structPtr atIndex:(NSUInteger)idx;

+(JRPointer*)packToStruct:(NSString*)objcTypeEncode values:(NSArray*)values;

+(id)callCFunction:(NSString*)functionName funcTypeEncode:(NSString*)funcTypeEncode arguments:(NSArray*)arguments;

-(void)testBlock;

@end
