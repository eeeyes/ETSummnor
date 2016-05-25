//
//  ETClassSummoner.m
//  XIBConverter
//
//  Created by chaoran on 16/5/19.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import "ETClassSummoner.h"

#import <objc/runtime.h>

#import "ffi.h"

#import "JRTypeEncodeParser.h"

static NSMutableArray* registeredClassArray = nil;
//static char jsFuncDict;

// char jsPropertyDict;

@interface ETMethod()
{
    ffi_cif* cif_ptr;
    
    ffi_type **args;
    
    ffi_closure *closure;
    
    void* impPtr;
}

@property (nonatomic,strong) JRTypeEncodeNode* methodEncodeNode;

@end

void methodImpInterpreter(ffi_cif* cif,void*ret,void**args,void*userdata)
{
    ETMethod* oc_method = (__bridge ETMethod*)userdata;
    
    JRTypeEncodeNode* arrayNode = oc_method.methodEncodeNode;
    
    JRTypeEncodeNode* returnNode = arrayNode.childNodes.firstObject;
    
    NSUInteger argumentCount = [arrayNode.childNodes count] - 1 ;
    
    NSMutableArray* jsArgumentArray = [NSMutableArray array];
    
    for(int i = 0 ; i < argumentCount ; i++){
        
        JRTypeEncodeNode* node = arrayNode.childNodes[i+1];
        
        void* argumentPtr = args[i];
        
        id value = [node copyPtrToValue:argumentPtr];
        
        [jsArgumentArray addObject:value];
        
    }
    
    id jsResult = [[oc_method.jsFunc callWithArguments:jsArgumentArray]toObject];
    
    [returnNode copyValue:jsResult toPtr:ret];
    
}

@implementation ETMethod

-(void*)generateImpPtr
{
    
    JRTypeEncodeParser* encodeParser = [[JRTypeEncodeParser alloc]init];
    
    encodeParser.typeEncodeStr = self.methodEncode;
    
    JRTypeEncodeNode* arrayNode = [encodeParser startParse];
    
    self.methodEncodeNode = arrayNode;
    
    JRTypeEncodeNode* returnNode = arrayNode.childNodes.firstObject;
    
    ffi_type* returnType = [returnNode ffiType];
    
    NSUInteger argumentCount = [arrayNode.childNodes count] - 1;
    
    
    
    cif_ptr = malloc(sizeof(ffi_cif));
    
    void* methodImp = NULL;
    
    args = malloc(sizeof(ffi_type*) * argumentCount) ;
    
    for(int i = 0 ; i < argumentCount ; i++){
        
        JRTypeEncodeNode* currentNode = arrayNode.childNodes[i+1];
        
        ffi_type* current_ffi_type = [currentNode ffiType];
        
        args[i] = current_ffi_type;
        
    }
    
    
    
    closure = ffi_closure_alloc(sizeof(ffi_closure), (void**)&methodImp);
    
    if(ffi_prep_cif(cif_ptr, FFI_DEFAULT_ABI, (unsigned int)argumentCount,returnType, args)==FFI_OK){
        
        if (ffi_prep_closure_loc(closure, cif_ptr, methodImpInterpreter,
                                 (__bridge void*)self, methodImp) == FFI_OK)
        {
            
            
        }
        
    }
    
    [returnNode freeFFiType:returnType];
    
    
    impPtr = methodImp;
    
    
    return impPtr;

}
-(void)dealloc
{
    ffi_closure_free(closure);
    
    free(args);
    
    free(cif_ptr);
    
    return;

}
@end

@interface ETClass()
@property (nonatomic,strong) Class aClass;
@end

@implementation ETClass

-(id)newObj
{
   
    id obj = [[_aClass alloc]init];
    
        //objc_setAssociatedObject(obj, &jsFuncDict, self.funcDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return obj;
    
}

@end

@implementation ETClassSummoner

-(ETClass*)registerClassNamed:(NSString *)className superClassName:(NSString *)superClassName funcDic:(NSDictionary *)funcDict
{
    if(!registeredClassArray){
        
        registeredClassArray = [NSMutableArray array];
        
    }
    
    ETClass* newClass = [[ETClass alloc]init];
    
    [registeredClassArray addObject:newClass];
    
    newClass.superClassName = superClassName;
    
    newClass.className = className;
    
    newClass.funcDict = funcDict;
    
    newClass.superClassName = superClassName;
    
    ///!!! this should be called only once
    
   newClass.aClass  = objc_allocateClassPair(NSClassFromString(superClassName), [className UTF8String], 0);
    
    [newClass.funcDict enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull funcName, ETMethod*  _Nonnull method, BOOL * _Nonnull stop) {
        
        const char* types = [method.methodEncode UTF8String];
        
        void* imp = [method generateImpPtr];
        
        class_addMethod(newClass.aClass, NSSelectorFromString(funcName), (IMP)imp, types);
        
        
    }];
    
    //register this class
    
    objc_registerClassPair(newClass.aClass);
    
    return newClass;
}

@end
