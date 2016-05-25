//
//  ETJSSummoner.m
//  XIBConverter
//
//  Created by chaoran on 16/5/18.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import "ETJSSummoner.h"

#import "ETSummoner.h"

#import "ETClassSummoner.h"

#import "ETBlockSummoner.h"

#import <dlfcn.h>

#import "JSRunner.h"

#import "JRTypeEncodeParser.h"

#import <objc/message.h>

static char jsPropertyDict;

@implementation ETJSSummoner

+(void)travelTypeNode:(JRTypeEncodeNode*)node bytes:(void*)value_ptr currentIndex:(NSUInteger*)idxPtr values:(NSArray*)values
{
    if(node.nodeType == JRTypeEncodeNodeTypeStruct){
        
        for(JRTypeEncodeNode* childNode in node.childNodes){
            
            [self travelTypeNode:childNode bytes:value_ptr currentIndex:idxPtr values:values];
            
        }
        
    }else{
        
        size_t mem_offset = node.mem_start_offset;
        
        value_ptr = value_ptr + mem_offset;
        
        [node copyValue:values[*idxPtr] toPtr:value_ptr];
        
        *idxPtr = *idxPtr + 1;
        
    }
}

+(JRPointer*)packValues:(NSArray*)arguments typeEncode:(NSString*)typeEncode
{
    JRTypeEncodeParser* parser = [[JRTypeEncodeParser alloc]init];
    
    parser.typeEncodeStr = typeEncode;
    
    JRTypeEncodeNode* arrayNode = [parser startParse];
    
    JRTypeEncodeNode* rootNode = arrayNode.childNodes.firstObject;
    
    size_t size = rootNode.mem_size;
    
    void* structPtr = alloca(size);
    
    NSUInteger currentIdx = 0;
    
    [self travelTypeNode:rootNode bytes:structPtr currentIndex:&currentIdx values:arguments];
    
    NSValue* structValue = [NSValue valueWithBytes:structPtr objCType:[typeEncode UTF8String]];
    
    JRPointer* jrPointer = [[JRPointer alloc]init];
    
    jrPointer.obj = structValue;
    
    return jrPointer;
}

+(JRTypeEncodeNode*)getChildNodeAtIndex:(NSUInteger)idx inRootNode:(JRTypeEncodeNode*)rootNode currentIdxPtr:(NSUInteger*)cidxPtr
{
    JRTypeEncodeNode* foundedNode = nil;
    
    if(rootNode.nodeType == JRTypeEncodeNodeTypeStruct){
        
        for(JRTypeEncodeNode* childNode in rootNode.childNodes){
            
            foundedNode = [self getChildNodeAtIndex:idx inRootNode:childNode currentIdxPtr:cidxPtr];
            
            if(foundedNode){
                
                return foundedNode;
            }
            
        }
        
    }else{
        
        if(*cidxPtr == idx){
            
            return rootNode;
            
        }
        
        *cidxPtr = *cidxPtr + 1;
    }
    
    return nil;

}

+(id)unPackValue:(JRPointer *)value  atIndex:(NSUInteger)idx
{
    NSValue* ns_value = value.obj;
    
    JRTypeEncodeParser* parser = [[JRTypeEncodeParser alloc]init];
    
    parser.typeEncodeStr = [NSString stringWithUTF8String: ns_value.objCType ];
    
    JRTypeEncodeNode* arrayNode = [parser startParse];
    
    JRTypeEncodeNode* rootNode = arrayNode.childNodes.firstObject;
    
    NSUInteger currentIdx = 0;
    
    JRTypeEncodeNode* childNode = [self getChildNodeAtIndex:idx inRootNode:rootNode currentIdxPtr:&currentIdx];
    
   
    
    void* valuePtr = alloca(rootNode.mem_size);
    
    [ns_value getValue:valuePtr];
    
    return [childNode copyPtrToValue:valuePtr+childNode.mem_start_offset];
    
}
+(JSContext*)initJSContext
{
    ETClassSummoner* classSummoner = [[ETClassSummoner alloc]init];
    
    JSContext* context = [[JSContext alloc]init];
    
    context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        
        NSLog(@"JS Error: %@", exception);
        
        return ;
        
    };

    context[@"callCFunction"]=^id (NSString* funcName,NSString* funcTypeEncode,NSArray* arguments){
        
        void* funcPtr = dlsym(RTLD_DEFAULT, [funcName UTF8String]);
        
        if(!funcPtr){
            
            return nil;
            
        }
        
        id result = [ETSummoner callCFunction:funcPtr funcTypeEncode:funcTypeEncode arguments:arguments];
        
        return result;
        
    };
    
    context[@"callCVarFunction"]=^id (NSString* funcName,NSString* funcTypeEncode,NSUInteger fixedArgumentCount, NSArray* arguments){
        
        void* funcPtr = dlsym(RTLD_DEFAULT, [funcName UTF8String]);
        
        if(!funcPtr){
            
            return nil;
            
        }

        id result = [ETSummoner callCVarFunction:funcPtr funcTypeEncode:funcTypeEncode fixedArgumentCount:fixedArgumentCount arguments:arguments];
        
        return result;
    };
    
    
    context[@"callObjcFunction"]=^id (NSString* selStr,NSString* typeEncode,NSArray* arguments){
        
        return [ETSummoner v2CallObjcFunction:selStr funcTypeEncode:typeEncode arguments:arguments];
        
    };
    
    context[@"callObjcSuperFunction"]=^id (NSString* selStr,NSString* typeEncode,NSArray* arguments){
        
        return [ETSummoner callObjcSuperFunction:selStr funcTypeEncode:typeEncode arguments:arguments];
        
    };
    
    context[@"packValues"] =^id (NSArray* values,NSString* typeEncode){
      
        return [ETJSSummoner  packValues:values typeEncode:typeEncode];
        
    };
    
    context[@"unpackValue"] =^ id (JRPointer* value,NSUInteger index){
        
        return [ETJSSummoner unPackValue:value atIndex:index];
        
    };
    
    context[@"newBlock"] =^ id (NSString* typeEncode,JSValue* jsFunction){
      
        ETBlockSummoner* blockSummoner = [[ETBlockSummoner alloc]init];
        
        blockSummoner.jsFunction = jsFunction;
        
        blockSummoner.blockTypeEncode = typeEncode;
        
        JRPointer* blockPtr = [[JRPointer alloc]init];
        
        blockPtr.isBlock = YES;
        
        blockPtr.obj = blockSummoner;
        
        return blockPtr;
    };
    
    context[@"getObj"]=^id (JRPointer* ptr){
      
        return [ptr obj];
        
    };
    
    context[@"isNull"]=^BOOL (JRPointer* ptr){
        
        return [ptr obj] == nil;
    };
    
    __weak JSContext* self_context = context;
    
    context[@"registerClass"]=^id (NSDictionary* classDefineDic){
        
        NSString* className = classDefineDic[@"class_name"];
        
        NSString* superClassName = classDefineDic[@"super_class_name"];
        
        NSArray* funcs = classDefineDic[@"funcs"];
        
        NSMutableDictionary* funcDic = [NSMutableDictionary dictionary];
        
        [funcs enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull methodDefDic, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString* methodName = methodDefDic[@"method_name"];
            
            NSString* methodEncode = methodDefDic[@"method_encode"];
            
            NSString* methodImpString = methodDefDic[@"method_imp"];
            
            JSValue* methodImp = self_context[methodImpString];
            
            ETMethod* newMethod = [[ETMethod alloc]init];
            
            newMethod.methodEncode = methodEncode;
            
            newMethod.jsFunc = methodImp;
            
            funcDic[methodName] = newMethod;
            
        }];
        
        ETClass* newClass = [classSummoner registerClassNamed:className superClassName:superClassName  funcDic:funcDic];
        
        JRPointer* classPtr = [[JRPointer alloc]init];
        
        classPtr.obj = newClass;
        
        return classPtr;
        
    };
    
    context[@"getPropertyDict"]=^id (JRPointer* objPtr){
        
        id obj = objPtr.obj;
        
        JRPointer* dictPtr = [[JRPointer alloc]init];
        
        NSMutableDictionary* dict = objc_getAssociatedObject(obj, &jsPropertyDict);
        
        if(!dict){
            
            dict = [NSMutableDictionary dictionary];
            
            objc_setAssociatedObject(obj, &jsPropertyDict, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

            
        }
        
        dictPtr.obj = dict;
        
        return dictPtr;
        
    };
    
    
    context[@"CGFloatEncode"]=^id (void){
      
        return [JRTypeEncodeNode CGFloatEncode];
        
    };
    
    context[@"NSIntegerEncode"]=^ id (void){
        
        return [JRTypeEncodeNode NSIntegerEncode];
        
    };
    
    context[@"NSUIntegerEncode"]=^ id(void){
        
        return [JRTypeEncodeNode NSUIntegerEncode];
        
    };
    
    return context;
}

@end
