//
//  ETSummoner.m
//  XIBConverter
//
//  Created by chaoran on 16/5/17.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import "ETSummoner.h"
#import "ffi.h"
#import "JRTypeEncodeParser.h"
#import "JSRunner.h"
#import "ETBlockSummoner.h"
#import <objc/runtime.h>

@implementation ETSummoner

+(id)callCFunction:(void*)functionPtr funcTypeEncode:(NSString*)funcTypeEncode arguments:(NSArray*)arguments
{
    return [self callCUniversalFunction:functionPtr funcTypeEncode:funcTypeEncode isVar:NO fixedArgumentCount:0 arguments:arguments];
}

+(id)callCVarFunction:(void *)functionPtr funcTypeEncode:(NSString *)functypeEncode fixedArgumentCount:(NSUInteger)fixedArgumentCount arguments:(NSArray *)arguments
{    
    return [self callCUniversalFunction:functionPtr funcTypeEncode:functypeEncode isVar:YES fixedArgumentCount:fixedArgumentCount arguments:arguments];
}

+(id)callCUniversalFunction:(void*)functionPtr funcTypeEncode:(NSString*)funcTypeEncode isVar:(BOOL)isVar fixedArgumentCount:(NSUInteger)fixedArgumentCount arguments:(NSArray*)arguments
{
    JRTypeEncodeParser* typeEncodeParser = [[JRTypeEncodeParser alloc]init];
    
    typeEncodeParser.typeEncodeStr = funcTypeEncode;
    
    JRTypeEncodeNode* arrayNode = [typeEncodeParser startParse];
    
    JRTypeEncodeNode* returnNode = arrayNode.childNodes.firstObject;
    
    NSUInteger argument_count = arrayNode.childNodes.count - 1;
    
    if( argument_count != [arguments count] ){
        
        return nil;
        
    }
    
    ffi_type** arg_types = alloca(sizeof(ffi_type*) * argument_count);
    
    void** args = alloca(sizeof(void*) * argument_count);
    
    for(int idx = 0 ; idx < argument_count ; idx ++){
        
        JRTypeEncodeNode* argumentTypeNode = arrayNode.childNodes[idx+1];
        
        ffi_type* current_arg_type = [argumentTypeNode ffiType];
        
        arg_types[idx] = current_arg_type;
        
        size_t typeSize = [argumentTypeNode size];
        
        void* destPtr = alloca(typeSize);
        
        [argumentTypeNode copyValue:arguments[idx] toPtr:destPtr];
        
        args[idx] = destPtr;
        
    }
    
    ffi_cif cif;
    
    id callResult = nil;
    
    ffi_type* ffi_type_return_ptr = [returnNode ffiType];
    
    ffi_status ffi_prep_status;
    
    if(!isVar){
        
        ffi_prep_status= ffi_prep_cif(&cif, FFI_DEFAULT_ABI, (unsigned int)argument_count,
                                     ffi_type_return_ptr, arg_types) ;
    
    }else{
        
        ffi_prep_status = ffi_prep_cif_var(&cif, FFI_DEFAULT_ABI, (unsigned int)fixedArgumentCount, (unsigned int)argument_count, ffi_type_return_ptr, arg_types);
        
    }
    
    if(ffi_prep_status == FFI_OK){
        
        void* returnPtr = NULL;
        
        if(returnNode.mem_size){
        
            returnPtr = alloca(returnNode.mem_size);
            
        }
        
        ffi_call(&cif, functionPtr, returnPtr, args);
        
        if(returnNode.mem_size){
         
            callResult = [returnNode copyPtrToValue:returnPtr];
            
        }
    }
    
    [returnNode freeFFiType:ffi_type_return_ptr];
    
    for(int idx = 0 ; idx < argument_count ; idx ++){
        
        JRTypeEncodeNode* argumentTypeNode = arrayNode.childNodes[idx+1];
        
        ffi_type* current_arg_type = arg_types[idx];
        
        [argumentTypeNode freeFFiType:current_arg_type];
        
    }
    
    return callResult;
    
}
+(id)getObjcTarget:(id)target
{
    if([target isKindOfClass:[JRPointer class]]){
        
        return [target obj];
    }
    
    return target;
}

+(id)v2CallObjcFunction:(NSString *)selectorStr funcTypeEncode:(NSString *)functypeEncode arguments:(NSArray *)arguments
{
    id realTarget = arguments[0] ;
    
    id target = arguments[0];
    
    if([target isKindOfClass:[JRPointer class]]){
        
        realTarget = [target obj];
    }
    
   
    SEL theSelector = NSSelectorFromString(selectorStr);
    
    IMP imp = class_getMethodImplementation(object_getClass(realTarget), NSSelectorFromString(selectorStr));
    
    JRPointer* selPtr = [[JRPointer alloc]init]; selPtr.ptr = (void*)theSelector;
    
    NSMutableArray* newArguments = [NSMutableArray arrayWithArray:arguments];
    
    [newArguments insertObject:selPtr atIndex:1];
    
    return [ETSummoner callCFunction:(void*)imp funcTypeEncode:functypeEncode arguments:newArguments];
}

+(id)callObjcSuperFunction:(NSString *)selectorStr funcTypeEncode:(NSString *)functypeEncode arguments:(NSArray *)arguments
{
    id realTarget = arguments[0] ;
    
    id target = arguments[0];
    
    if([target isKindOfClass:[JRPointer class]]){
        
        realTarget = [target obj];
    }
    
    
    SEL theSelector = NSSelectorFromString(selectorStr);
    
    IMP imp = class_getMethodImplementation([object_getClass(realTarget) superclass], NSSelectorFromString(selectorStr));
    
    JRPointer* selPtr = [[JRPointer alloc]init]; selPtr.ptr = (void*)theSelector;
    
    NSMutableArray* newArguments = [NSMutableArray arrayWithArray:arguments];
    
    [newArguments insertObject:selPtr atIndex:1];
    
    return [ETSummoner callCFunction:(void*)imp funcTypeEncode:functypeEncode arguments:newArguments];

}

@end
