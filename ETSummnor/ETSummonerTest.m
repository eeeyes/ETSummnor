//
//  ETSummonerTest.m
//  XIBConverter
//
//  Created by chaoran on 16/5/17.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import "ETSummonerTest.h"

#import "ETSummoner.h"

#import <UIKit/UIKit.h>

#import "JSRunner.h"

#import <dlfcn.h>

#import "ETJSSummoner.h"

#import "JRTypeEncodeParser.h"

#import "ETBlockSummoner.h"

#import "ETClassSummoner.h"

#import <objc/message.h>


typedef struct Foo
{
    char a;
    
    double v;
    
    void* p;
    
}Foo;

typedef struct Foo2
{
    char a;
    
    double v;
    
    char b;
    
}Foo2;

int addValue(int x,int y)
{
    return x + y;
}

CGRect makeCGRect(CGFloat x,CGFloat y, CGFloat width,CGFloat height)
{
    return CGRectMake(x, y, width, height);
}

Foo makeFoo(char a,double v,void* p)
{
    Foo foo;
    
    foo.a = a;
    
    foo.v = v;
    
    foo.p = p;
    
    return foo;
}

CGFloat getWidth(CGRect rect)
{
    return rect.size.width;
}

char* etPuts(char* a,char* b)
{
    NSLog(@"%s",a);
    
    NSLog(@"%s",b);
    
    return b;
}

@implementation ETSummonerTest
+(void)testAddValueFunction
{
    NSNumber* returnValue = [ETSummoner callCFunction:addValue  funcTypeEncode:@"iii" arguments:@[@500,@19]];
    
    NSLog(@"result is %d",[returnValue intValue]);
}
+(void)testMakeCGRectFunction
{
    NSString* CGfloatEncode = [JRTypeEncodeNode CGFloatEncode];
    
    NSString* cgRectEncode = [NSString stringWithFormat: @"{x={y=%@%@}{y=%@%@}}",CGfloatEncode,CGfloatEncode,CGfloatEncode,CGfloatEncode];
    
    NSString* makeCGRectFunctionTypeEncode = [NSString stringWithFormat:@"%@%@%@%@%@",cgRectEncode,CGfloatEncode,CGfloatEncode,CGfloatEncode,CGfloatEncode];
    
    JRPointer* returnStructPointer = [ETSummoner callCFunction:makeCGRect funcTypeEncode:makeCGRectFunctionTypeEncode arguments:@[@0,@0,@320,@519]];
    
    NSValue* returnCGRectValue = returnStructPointer.obj;
    
    CGRect returnRect ;
    
    [returnCGRectValue getValue:&returnRect];
    
    NSLog(@"result is %@",NSStringFromCGRect(returnRect));
    
}
+(void)testMakeFooFunction
{
    NSString* FooEncode = @"{x=cd^v}";
    
    NSString* mkFooFuncEnc = [NSString stringWithFormat:@"%@cd^v",FooEncode];
    
    JRPointer* fooPtr = [[JRPointer alloc]init]; fooPtr.ptr = NULL;
    
    NSArray*  mkFooArgs = @[[NSNumber numberWithChar:'b'],@519,fooPtr ];
    
    JRPointer* returnFooPointer = [ETSummoner callCFunction:makeFoo funcTypeEncode:mkFooFuncEnc arguments:mkFooArgs];
    
    Foo returnFoo;
    
    NSValue* returnFooValue = returnFooPointer.obj;
    
    [returnFooValue getValue:&returnFoo];
    
    NSLog(@"a is %c,v is %f,p is %p",returnFoo.a,returnFoo.v,returnFoo.p);
}
+(void)testGetWidth
{
    NSString* CGfloatEncode = [JRTypeEncodeNode CGFloatEncode];
    
    NSString* cgRectEncode = [NSString stringWithFormat: @"{x={y=%@%@}{y=%@%@}}",CGfloatEncode,CGfloatEncode,CGfloatEncode,CGfloatEncode];
    
    NSString* funcTypeEncode = [NSString stringWithFormat:@"%@%@",CGfloatEncode,cgRectEncode];
    
    CGRect rect = CGRectMake(1.0, 2.0, 3.0, 4.0);
    
    NSValue* cgRectValue = [NSValue valueWithBytes:&rect  objCType:[cgRectEncode UTF8String]];
    
    JRPointer* pt = [[JRPointer alloc]init]; pt.obj = cgRectValue;
    
    NSNumber* r = [ETSummoner callCFunction:getWidth funcTypeEncode:funcTypeEncode arguments:@[pt]];
    
    NSLog(@"width is %lf",[r doubleValue]);
    
    return;
}
+(void)testNSLog
{
    NSString* funcTypeEncode = @"v@@";
    
    JRPointer* formatString = [[JRPointer alloc]init]; formatString.obj = @"%@";
    
    JRPointer* objString = [[JRPointer alloc]init]; objString.obj = @"HELLO WORLD FROM NSLOG v1";
    
    [ETSummoner callCVarFunction:NSLog funcTypeEncode:funcTypeEncode fixedArgumentCount:1 arguments:@[formatString,objString]];
    
    return;
}
+(void)testNSLogV2
{
    NSString* funcTypeEncode = @"v@@";
    
    [ETSummoner callCVarFunction:NSLog funcTypeEncode:funcTypeEncode fixedArgumentCount:1 arguments:@[@"%@",@"HELLO WORLD FROM NSLOG v2"]];
    
    return;

}
+(void)testPointerArgument
{
    char* a = "test";
    
    char* b = "19890519";
    
    JRPointer* aStr = [[JRPointer alloc]init]; aStr.ptr = a;
    
    JRPointer* bStr = [[JRPointer alloc]init]; bStr.ptr = b;
    
    JRPointer* rt = [ETSummoner callCFunction:etPuts funcTypeEncode:@"^v^v^v" arguments:@[aStr,bStr]];
    
    NSLog(@"%s",(char*)rt.ptr);
}

+(void)testCreateNSObject
{
    JRPointer* classPointer = [[JRPointer alloc]init];
    
    classPointer.obj = [NSObject class];
    
    JRPointer* newObjPtr = [ETSummoner v2CallObjcFunction:@"alloc" funcTypeEncode:@"@@:" arguments:@[classPointer]];
    
    newObjPtr = [ETSummoner v2CallObjcFunction:@"init" funcTypeEncode:@"@@:" arguments:@[newObjPtr]];
    
    NSLog(@"%@",newObjPtr.obj);
}

+(void)testArray
{
    JRPointer* classPointer = [[JRPointer alloc]init];
    
    classPointer.obj = NSClassFromString(@"NSMutableArray");
    
    JRPointer* newArrayPtr = [ETSummoner v2CallObjcFunction:@"alloc" funcTypeEncode:@"@@:" arguments:@[classPointer]];
    
    newArrayPtr = [ETSummoner v2CallObjcFunction:@"init" funcTypeEncode:@"@@:" arguments:@[newArrayPtr]];
    
    JRPointer* numberClassPointer = [[JRPointer alloc]init];
    
    numberClassPointer.obj = NSClassFromString(@"NSNumber");
    
    JRPointer* numPtr =[ETSummoner v2CallObjcFunction:@"numberWithInt:" funcTypeEncode:@"@@:i" arguments:@[numberClassPointer,@2]];
    
    NSLog(@"%@",numPtr.obj);
    
    [ETSummoner v2CallObjcFunction:@"addObject:" funcTypeEncode:@"@@:@" arguments:@[newArrayPtr,numPtr]];
    
    NSLog(@"%@",newArrayPtr.obj);
    
}

+(void)testCreateUIView
{
    JRPointer* viewClassPointer = [[JRPointer alloc]init];
    
    viewClassPointer.obj = NSClassFromString(@"UIView");
    
    JRPointer* newViewPtr = [ETSummoner v2CallObjcFunction:@"alloc" funcTypeEncode:@"@@:" arguments:@[viewClassPointer]];
    
    newViewPtr = [ETSummoner v2CallObjcFunction:@"init" funcTypeEncode:@"@@:" arguments:@[newViewPtr]];
    
    
    NSString* CGfloatEncode = [JRTypeEncodeNode CGFloatEncode];
    
    NSString* cgRectEncode = [NSString stringWithFormat: @"{x={y=%@%@}{y=%@%@}}",CGfloatEncode,CGfloatEncode,CGfloatEncode,CGfloatEncode];
    
    CGRect frame = CGRectMake(0, 0, 519, 519);
    
    JRPointer* framePtr = [[JRPointer alloc]init];
    
    NSValue* frameValue = [NSValue valueWithBytes:&frame objCType:[cgRectEncode UTF8String]];
    
    framePtr.obj = frameValue;
    
    [ETSummoner v2CallObjcFunction:@"setFrame:" funcTypeEncode:@"v@:{x=dddd}" arguments:@[newViewPtr,framePtr]];
    
    NSLog(@"%@",newViewPtr.obj);
    
    
    JRPointer* rfPtr = [ETSummoner v2CallObjcFunction:@"frame" funcTypeEncode:@"{x=dddd}@:" arguments:@[newViewPtr]];
    
    NSValue* rfv = rfPtr.obj;
    
    CGRect returnRect ;
    
    [rfv getValue:&returnRect];
    
    NSLog(@"%@",NSStringFromCGRect(returnRect));
    
    return;
    
}

+(void)testGenerateClass
{
   // NSClassFromString
    
    void* funcPtr = dlsym(RTLD_DEFAULT, "NSClassFromString");
    
    JRPointer* rtPointer = [ETSummoner callCFunction:funcPtr funcTypeEncode:@"#@" arguments:@[@"UIView"]];
    
    NSLog(@"%@",rtPointer.obj);
    
    return;
}

+(void)testPackValues
{
    NSString* CGfloatEncode = [JRTypeEncodeNode CGFloatEncode];
    
    NSString* cgRectEncode = [NSString stringWithFormat: @"{x={y=%@%@}{y=%@%@}}",CGfloatEncode,CGfloatEncode,CGfloatEncode,CGfloatEncode];
    
    JRPointer* rtPtr = [ETJSSummoner packValues:@[@0,@0,@1989,@519] typeEncode:cgRectEncode];
    
    CGRect rtRect;
    
    NSValue* rtValue = rtPtr.obj;
    
    [rtValue getValue:&rtRect];
    
    NSLog(@"%@",NSStringFromCGRect(rtRect));
    
    
    NSString* foo2Encode = @"{x=cdc}";
    
    rtPtr = [ETJSSummoner packValues:@[[NSNumber numberWithChar:'z'],@1989.0519,[NSNumber numberWithChar:'m']] typeEncode:foo2Encode];
    
    Foo2 foo;
    
    rtValue = rtPtr.obj;
    
    [rtValue getValue:&foo];
    
    NSLog(@"%c %f %c",foo.a,foo.v,foo.b);
    
    return;
}

+(void)testUnpackValue
{
    NSString* CGfloatEncode = [JRTypeEncodeNode CGFloatEncode];
    
    NSString* cgRectEncode = [NSString stringWithFormat: @"{x={y=%@%@}{y=%@%@}}",CGfloatEncode,CGfloatEncode,CGfloatEncode,CGfloatEncode];
    
    JRPointer* rtPtr = [ETJSSummoner packValues:@[@12,@34,@1989,@519] typeEncode:cgRectEncode];
    
    NSNumber* width = [ETJSSummoner unPackValue:rtPtr atIndex:2];
    
    NSLog(@"width is %f",[width doubleValue]);
    
    NSString* foo2Encode = @"{x=cdc}";
    
    rtPtr = [ETJSSummoner packValues:@[[NSNumber numberWithChar:'z'],@1989.0519,[NSNumber numberWithChar:'m']] typeEncode:foo2Encode];

    NSNumber* bd = [ETJSSummoner unPackValue:rtPtr atIndex:1];
    
    NSLog(@"bd is %f",[bd doubleValue]);
    
    return;
}

+(void)testJSBuildUI
{
    NSString* filePath = [[NSBundle mainBundle]pathForResource:@"testBuildUI" ofType:@"js"];
    
    NSString* jsContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    JSContext* context = [ETJSSummoner initJSContext];
    
    [context evaluateScript:jsContent];
    
    JRPointer* rt = [context[@"view"]toObject];
    
    NSLog(@"%@",rt.obj);
    
    return;
}

+(void)testJSBlock
{
    JSContext* jsContext = [ETJSSummoner initJSContext];
    
    NSString* jsPath = [[NSBundle mainBundle]pathForResource:@"testSort" ofType:@"js"];
    
    NSString* jsContent = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    
    [jsContext evaluateScript:jsContent];
    
    return;

}




+(void)testCallCFunctions
{
    [self testAddValueFunction];

    [self testMakeCGRectFunction];
    
    [self testMakeFooFunction];

    [self testGetWidth];
    
    [self testPointerArgument];
    
    [self testNSLog];
    
    [self testNSLogV2];
    
    [self testCreateNSObject];
    
    [self testArray];
    
    [self testCreateUIView];
    
    [self testGenerateClass];
   
    [self testPackValues];
    
    [self testUnpackValue];
//    
    [self testJSBuildUI];
    
    [self testJSBlock];
//    
   
    
 
    
    return;
}

+(void)testMsgSend
{
    UIView* testView = [[UIView alloc]initWithFrame:CGRectMake(1, 2, 4, 8)];
    
    IMP imp = class_getMethodImplementation([testView class], @selector(frame));
    
    CGRect viewRect = ((CGRect(*)(id, SEL))imp)(testView, @selector(frame));
    
    NSLog(@"%@",NSStringFromCGRect(viewRect));
    
    return;
    
}

+(void)testAutoGeneratedJS
{
    JSContext* jsContext = [ETJSSummoner initJSContext];
    
    NSString* jsContent = [NSString stringWithContentsOfFile:@"/tmp/auto.js" encoding:NSUTF8StringEncoding error:nil];
    
    [jsContext evaluateScript:jsContent];
    
    JSValue* f = jsContext[@"main"];
    
    [f callWithArguments:nil];
}
@end
