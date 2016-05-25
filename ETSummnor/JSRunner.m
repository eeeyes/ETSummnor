//
//  JSRunner.m
//  XIBConverter
//
//  Created by chaoran on 16/5/8.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import "JSRunner.h"
#import <UIkit/UIKit.h>
#import "JRTypeEncodeParser.h"
#import "ffi.h"
#import <dlfcn.h>

extern CGRect JRCGRectMake(CGFloat origin_x,CGFloat origin_y,CGFloat width,CGFloat height);

@implementation JRValue

@end

@implementation JRPointer
-(id)init
{
    self = [super init];
    
    if(self){
        
        self.isBlock = NO;
    }
    
    return self;
}
+(instancetype)JRPointerWithObj:(id)obj
{
    JRPointer* pointer = [[JRPointer alloc]init];
    
    pointer.obj = obj;
    
    return  pointer;
}
+(instancetype)JRPointerWithNSValue:(NSValue *)value
{
    JRValue* jrValue = [[JRValue alloc]init];
    
    jrValue.value=value;
    
    return [JRPointer JRPointerWithObj:jrValue];
    
}
-(NSString*)description
{
    return [NSString stringWithFormat: @"%p",_obj];
}
@end

@interface JSRunner()
{
    JSContext* _context;
    
    NSDictionary* _contextDict;
}
@end


JSContext* sharedContext = nil;

@interface JSRunner ()

@property (nonatomic,strong) NSMutableDictionary* jsFuncDic;

@end

@implementation JSRunner

-(JSContext*)sharedContext
{
    if(!sharedContext){
        
        sharedContext = [[JSContext alloc]init];
        
        sharedContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            
            NSLog(@"JS Error: %@", exception);
            
        };
        
        [[self class]registerContext];

    }
    
    return sharedContext;
}
+(JRPointer*)getValueFromStruct:(NSString*)objcTypeEncode value:(JRPointer*)structPtr atIndex:(NSUInteger)idx
{
    JRTypeEncodeParser* encodeParser = [[JRTypeEncodeParser alloc]init];
    
    encodeParser.typeEncodeStr = objcTypeEncode;
    
    JRTypeEncodeNode* arrayNode =  [encodeParser startParse];
    
    JRTypeEncodeNode* rootNode = [arrayNode.childNodes firstObject];
    
    JRTypeEncodeNode* childNode = rootNode.childNodes[idx];
    
    //[childNode caculateMemOffset];
    
    void* root_value_ptr = malloc(rootNode.mem_size);
    
    [((JRValue*)structPtr.obj).value getValue:root_value_ptr];
    
    void* child_value_ptr = malloc(childNode.mem_size);
    
    memcpy(child_value_ptr, (char*)root_value_ptr+childNode.mem_start_offset, childNode.mem_size);
    
    NSValue* childValue = [NSValue valueWithBytes:child_value_ptr objCType:[childNode.typeEncodeStr UTF8String]];
    

    JRPointer* jrPointer = [JRPointer JRPointerWithNSValue:childValue];
    
    free(root_value_ptr);
    
    free(child_value_ptr);
    
    return jrPointer;
}

+(void)travelNode:(JRTypeEncodeNode*)node bytes:(void*)value_ptr currentIndex:(NSUInteger*)idx values:(NSArray*)values
{
    if(![node.childNodes count]){
 
        NSUInteger mem_offset = node.mem_start_offset;
        
        //char current_char = [node.typeEncodeStr UTF8String][0];
        
        JRTypeEncodeNodeType type = node.nodeType;
        
        switch (type) {
                
            case JRTypeEncodeNodeTypeChar:{
                
                NSString* current_value = values[*idx];
                
                char current_value_char = [current_value UTF8String][0];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((char*)value_ptr_loc)[0]=current_value_char;
                
                break;
                
            }
                
            case JRTypeEncodeNodeTypeInt:{
                
                NSNumber* current_value = values[*idx];
                
                int current_value_int = [current_value intValue];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((int*)value_ptr_loc)[0]=current_value_int;
                
                break;
                
            }
                
            case JRTypeEncodeNodeTypeShort:{
                
                NSNumber* current_value = values[*idx];
                
                short current_value_short = [current_value shortValue];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((short*)value_ptr_loc)[0]=current_value_short;
                
                break;
                
            }
                
            case JRTypeEncodeNodeTypeLong:{
                
                NSNumber* current_value = values[*idx];
                
                long current_value_long = [current_value longValue];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((long*)value_ptr_loc)[0]=current_value_long;
                
                break;
                
            }
                
                
            case JRTypeEncodeNodeTypeLongLong:{
                
                NSNumber* current_value = values[*idx];
                
                long long current_value_longlong = [current_value longLongValue];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((long long*)value_ptr_loc)[0]=current_value_longlong;
                
                break;
                
            }
                
            case JRTypeEncodeNodeTypeUnsignedChar:{
                
                NSString* current_value = values[*idx];
                
                unsigned char current_value_char = [current_value UTF8String][0];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((unsigned char*)value_ptr_loc)[0]=current_value_char;
                
                break;
                
            }
                
                
            case JRTypeEncodeNodeTypeUnsignedInt:{
                
                NSNumber* current_value = values[*idx];
                
                unsigned int current_value_int = [current_value unsignedIntValue];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((unsigned int*)value_ptr_loc)[0] = current_value_int;
                
                break;
                
            }
                
            case JRTypeEncodeNodeTypeUnsignedShort:{
                
                NSNumber* current_value = values[*idx];
                
                unsigned short current_value_short = [current_value unsignedShortValue];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((unsigned short*)value_ptr_loc)[0]=current_value_short;
                
                break;
                
            }
                
            case JRTypeEncodeNodeTypeUnsignedLong:{
                
                NSNumber* current_value = values[*idx];
                
                unsigned long current_value_long = [current_value unsignedLongValue];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((unsigned long*)value_ptr_loc)[0]=current_value_long;
                
                break;
                
            }
                
                
            case JRTypeEncodeNodeTypeUnsignedLongLong:{
                
                NSNumber* current_value = values[*idx];
                
                unsigned long long current_value_long_long = [current_value unsignedLongLongValue];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((unsigned long long*)value_ptr_loc)[0]=current_value_long_long;
                
                break;
                
            }
                
            case JRTypeEncodeNodeTypeFloat:{
                
                NSNumber* current_value = values[*idx];
                
                float current_value_float = [current_value floatValue];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((float*)value_ptr_loc)[0] = current_value_float;
                
                break;
                
            }
                
            case JRTypeEncodeNodeTypeDouble:{
                
                NSNumber* current_value = values[*idx];
                
                double current_value_float = [current_value doubleValue];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((double*)value_ptr_loc)[0] = current_value_float;
                
                break;
                
            }
                
            case JRTypeEncodeNodeTypeBool:{
                
                NSNumber* current_value = values[*idx];
                
                BOOL current_value_float = [current_value boolValue];
                
                void* value_ptr_loc = value_ptr + mem_offset;
                
                ((BOOL*)value_ptr_loc)[0] = current_value_float;
                
                break;
                
            }
                
            default:
                
                break;
        }
        
        *idx = (*idx) + 1;
        
    }else{
        
        for(JRTypeEncodeNode* childNode in node.childNodes){
            
            [self travelNode:childNode bytes:value_ptr currentIndex:idx values:values];
            
        }
    }
}
+(JRPointer*)packToStruct:(NSString*)objcTypeEncode values:(NSArray*)values
{
    JRTypeEncodeParser* encodeParser = [[JRTypeEncodeParser alloc]init];
    
    encodeParser.typeEncodeStr = objcTypeEncode;
    
    JRTypeEncodeNode* arrayNode = [encodeParser startParse];
    
    JRTypeEncodeNode* rootNode = arrayNode.childNodes[0];
    
    NSUInteger mem_size = rootNode.mem_size;
    
    void* value_ptr = malloc(mem_size);
    
    NSUInteger idx = 0;
    
    [self travelNode:rootNode bytes:value_ptr currentIndex:&idx values:values] ;

    NSValue* nsvalue = [NSValue valueWithBytes:value_ptr objCType:[objcTypeEncode UTF8String]];
    
    free(value_ptr);
    
    return [JRPointer JRPointerWithNSValue:nsvalue];
}
+(NSNumber*)unpackValue:(NSString*)typeEncode value:(JRPointer*)valuePtr
{
    char current_char = [typeEncode UTF8String][0];
    
    NSValue* value = ((JRValue*)valuePtr.obj).value;
    
    switch (current_char) {
            
        case 'c':{
            
            char current_value_char = 0;
            
            [value getValue:&current_char];
            
            return [NSNumber numberWithChar:current_value_char];
        
            
        }
            
        case 'i':{
            
            int current_value_int = 0;
            
            [value getValue:&current_value_int];
            
            return [NSNumber numberWithInt:current_value_int];
        
        }
            
        case 's':{
            
            short current_value_short = 0;
            
            [value getValue:&current_value_short];
            
            return [NSNumber numberWithShort:current_value_short];
            
        }
            
        case 'l':{
            
            long current_value_long = 0;
            
            [value getValue:&current_value_long];
            
            return [NSNumber numberWithLong:current_value_long];
            
        }
            
            
        case 'q':{
            
            long long current_value_longlong = 0;
            
            [value getValue:&current_value_longlong];
            
            return [NSNumber numberWithLongLong:current_value_longlong];
            
        }
            
        case 'C':{
            
            unsigned char current_value_char = 0;
            
            [value getValue:&current_value_char];
            
            return [NSNumber numberWithUnsignedChar:current_value_char];
            
        }
            
            
        case 'I':{
            
            unsigned int current_value_int = 0;
            
            [value getValue:&current_value_int];
            
            return [NSNumber numberWithInt:current_value_int];
            
            break;
            
        }
            
        case 'S':{
            
            unsigned short current_value_short = 0;
            
            [value getValue:&current_value_short];
            
            return [NSNumber numberWithUnsignedShort:current_value_short];
            
        }
            
        case 'L':{
            
            unsigned long current_value_long = 0;
            
            [value getValue:&current_value_long];
            
            return [NSNumber numberWithUnsignedLong:current_value_long];
            
        }
            
            
        case 'Q':{
            
            unsigned long long current_value_long_long = 0;
            
            [value getValue:&current_value_long_long];
            
            return [NSNumber numberWithUnsignedLongLong:current_value_long_long];
            
        }
            
        case 'f':{
            
            float current_value_float = 0;
            
            [value getValue:&current_value_float];
            
            return [NSNumber numberWithFloat:current_value_float];
            
        }
            
        case 'd':{
            
            double current_value_double = 0;
            
            [value getValue:&current_value_double];
            
            return [NSNumber numberWithDouble:current_value_double];
            
        }
            
        case 'B':{
            
            BOOL current_value_bool = 0;
            
            [value getValue:&current_value_bool];
            
            return [NSNumber numberWithBool:current_value_bool];
            
        }

    }
    
    return nil;
}
+(JRPointer*)getClass:(NSString *)className
{
    Class objClass = NSClassFromString(className);
    
    return [JRPointer JRPointerWithObj:objClass];
}

+(void)callCVarFunction:(NSString*)functionName typeEncode:(NSString*)typeEncode arguments:(NSArray*)arguments
{
    
    
    
}

+(id)callCFunction:(NSString*)functionName funcTypeEncode:(NSString*)funcTypeEncode arguments:(NSArray*)arguments
{
    
   void* funcPtr = dlsym(RTLD_MAIN_ONLY, [functionName UTF8String]);
    
    if(!funcPtr){
        
        return nil;
    }
    
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
        
        switch (argumentTypeNode.nodeType) {
                
            case JRTypeEncodeNodeTypeChar:{
                
                NSNumber* current_argument = arguments[idx];
                
                char* current_argument_value_ptr = alloca(sizeof(char));
                
                *current_argument_value_ptr = [current_argument charValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;
            }
                
            case JRTypeEncodeNodeTypeShort:{
                
                NSNumber* current_argument = arguments[idx];
                
                short* current_argument_value_ptr = alloca(sizeof(short));
                
                *current_argument_value_ptr = [current_argument shortValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;
                
            }
             
            case JRTypeEncodeNodeTypeInt:{
                
                NSNumber* current_argument = arguments[idx];
                
                int* current_argument_value_ptr = alloca(sizeof(int));
                
                *current_argument_value_ptr = [current_argument intValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;
                
            }
             
            case JRTypeEncodeNodeTypeLong:{
                
                NSNumber* current_argument = arguments[idx];
                
                long* current_argument_value_ptr = alloca(sizeof(long));
                
                *current_argument_value_ptr = [current_argument longValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;
            }
                
            case JRTypeEncodeNodeTypeLongLong:{
                
                NSNumber* current_argument = arguments[idx];
                
                long long* current_argument_value_ptr = alloca(sizeof(long long));
                
                *current_argument_value_ptr = [current_argument longLongValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;
            }
                
            case JRTypeEncodeNodeTypeUnsignedChar:{
                
                NSNumber* current_argument = arguments[idx];
                
                unsigned char* current_argument_value_ptr = alloca(sizeof(unsigned char));
                
                *current_argument_value_ptr = [current_argument unsignedCharValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;
            }
                
            case JRTypeEncodeNodeTypeUnsignedShort:{
                
                NSNumber* current_argument = arguments[idx];
                
                unsigned short* current_argument_value_ptr = alloca(sizeof(unsigned short));
                
                *current_argument_value_ptr = [current_argument unsignedShortValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;
                
            }
                
            case JRTypeEncodeNodeTypeUnsignedInt:{
                
                NSNumber* current_argument = arguments[idx];
                
                unsigned int* current_argument_value_ptr = alloca(sizeof(unsigned int));
                
                *current_argument_value_ptr = [current_argument unsignedIntValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;
            }
                
            case JRTypeEncodeNodeTypeUnsignedLong:{
                
                NSNumber* current_argument = arguments[idx];
                
                unsigned long* current_argument_value_ptr = alloca(sizeof(unsigned long));
                
                *current_argument_value_ptr = [current_argument unsignedLongValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;
            }
                
            case JRTypeEncodeNodeTypeUnsignedLongLong:{
                
                NSNumber* current_argument = arguments[idx];
                
                unsigned long long* current_argument_value_ptr = alloca(sizeof(unsigned long long));
                
                *current_argument_value_ptr = [current_argument unsignedLongLongValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;
            }
                
            case JRTypeEncodeNodeTypeFloat:{
                
                NSNumber* current_argument = arguments[idx];
                
                float* current_argument_value_ptr = alloca(sizeof(float));
                
                *current_argument_value_ptr = [current_argument floatValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;;
            }
                
            case JRTypeEncodeNodeTypeDouble:{
                
                NSNumber* current_argument = arguments[idx];
                
                double* current_argument_value_ptr = alloca(sizeof(double));
                
                *current_argument_value_ptr = [current_argument doubleValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;
            }
                
            case JRTypeEncodeNodeTypeBool:{
                
                NSNumber* current_argument = arguments[idx];
                
                BOOL* current_argument_value_ptr = alloca(sizeof(BOOL));
                
                *current_argument_value_ptr = [current_argument boolValue];
                
                args[idx] = current_argument_value_ptr;
                
                break;
            }
              
            case JRTypeEncodeNodeTypeVoid:{
                
                break;
            }
                
            case JRTypeEncodeNodeTypeCharPointer:{
                
                if([arguments[idx] isKindOfClass:[JRPointer class]]){
                    
                    JRPointer* current_argument = arguments[idx];
                
                    void* ptr = current_argument.ptr;
                
                    args[idx] = &ptr;
                    
                    break;
                }
                
                if([arguments[idx] isKindOfClass:[NSString class]]){
                    
                    NSString* current_argument = arguments[idx];
                    
                    const char* ptr = [current_argument UTF8String];
                    
                    args[idx] = &ptr;
                    
                    break;
                }
            }
                
            case JRTypeEncodeNodeTypeClassObj:
            case JRTypeEncodeNodeTypeObj:{
                
                JRPointer* current_argument = arguments[idx];
                
                id ptr = current_argument.obj;
                
                args[idx] = &ptr;
                
                break;
            }
                
            case JRTypeEncodeNodeTypeStruct:{
                
                JRPointer* current_argument = arguments[idx];
                
                NSValue* current_argument_value = current_argument.obj;
                
                void* value_ptr = alloca(sizeof(argumentTypeNode.mem_size));
                
                [current_argument_value getValue:value_ptr];
                
                args[idx] = value_ptr;
                
                break;
            }
                
            case JRTypeEncodeNodeTypePointer:{
                
                JRPointer* current_argument = arguments[idx];
                
                void* ptr = current_argument.ptr;
                
                args[idx] = &ptr;
                
                break;
            }
                
            default:
                break;
        }
        
        
    }
    
    ffi_cif cif;
    
    void* returnPtr = alloca(returnNode.mem_size);
    
    ffi_type* ffi_type_struct_ptr = [returnNode ffiType];
    
    if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, (unsigned int)argument_count,
                     ffi_type_struct_ptr, arg_types) == FFI_OK)
    {
        
        ffi_call(&cif, funcPtr, returnPtr, args);
       
    }
    
    [returnNode freeFFiType:ffi_type_struct_ptr];
    
    for(int idx = 0 ; idx < argument_count ; idx ++){
        
        JRTypeEncodeNode* argumentTypeNode = arrayNode.childNodes[idx+1];
        
        ffi_type* current_arg_type = arg_types[idx];
        
        [argumentTypeNode freeFFiType:current_arg_type];
        
    }
    
    switch (returnNode.nodeType) {
            
        case JRTypeEncodeNodeTypeChar:{
            
            char returnValue = *(char*)returnPtr;
            
            return [NSNumber numberWithChar:returnValue];

        }
        
            
        case JRTypeEncodeNodeTypeShort:{
            
            short returnValue = *(short*)returnPtr;
            
            return [NSNumber numberWithShort:returnValue];
    
        }
            
        case JRTypeEncodeNodeTypeInt:{
            
            int returnValue = *(int*)returnPtr;
            
            return [NSNumber numberWithInt:returnValue];

        }
            
        case JRTypeEncodeNodeTypeLong:{
            
            long returnValue = *(long*)returnPtr;
            
            return [NSNumber numberWithLong:returnValue];
            
        }
            
        case JRTypeEncodeNodeTypeLongLong:{
            
            long long returnValue = *(long long*)returnPtr;
            
            return [NSNumber numberWithLongLong:returnValue];
        }
            
            //
            
        case JRTypeEncodeNodeTypeUnsignedChar:{
            
            unsigned char returnValue = *(unsigned char*)returnPtr;
            
            return [NSNumber numberWithUnsignedChar:returnValue];
         
        }
        
        case JRTypeEncodeNodeTypeUnsignedShort:{
            
            unsigned short returnValue = *(unsigned short*)returnPtr;
            
            return [NSNumber numberWithUnsignedShort:returnValue];
            
        }
            
        case JRTypeEncodeNodeTypeUnsignedInt:{
            
            unsigned int returnValue = *(unsigned int*)returnPtr;
            
            return [NSNumber numberWithUnsignedInt:returnValue];
        }
            
        case JRTypeEncodeNodeTypeUnsignedLong:{
            
            unsigned long returnValue = *(unsigned long*)returnPtr;
            
            return [NSNumber numberWithUnsignedLong:returnValue];
            
        }
            
        case JRTypeEncodeNodeTypeUnsignedLongLong:{
            
            unsigned long long returnValue = *(unsigned long long*)returnPtr;
            
            return [NSNumber numberWithUnsignedLongLong:returnValue];
            
        }
            
          //
        case JRTypeEncodeNodeTypeFloat:{
            
            float returnValue = *(float*)returnPtr;
            
            return [NSNumber numberWithFloat: returnValue];
        }
            
        case JRTypeEncodeNodeTypeDouble:{
            
            double returnValue = *(double*)returnPtr;
            
            return [NSNumber numberWithDouble:returnValue];
            
        }
        case JRTypeEncodeNodeTypeBool:{
            
            BOOL returnValue = *(BOOL*)returnPtr;
            
            return [NSNumber numberWithBool:returnValue];
            
        }
            
        case JRTypeEncodeNodeTypeVoid:{
            
            return NULL;
        }
          
        case JRTypeEncodeNodeTypeCharPointer:{
            
            JRPointer* jrPointer = [[JRPointer alloc]init];
            
            jrPointer.ptr = *(char**)returnPtr;
            
            return jrPointer;
            
        }

        case JRTypeEncodeNodeTypeClassObj:
        case JRTypeEncodeNodeTypeObj:{
            
            JRPointer* jrPointer = [[JRPointer alloc]init];
            
            jrPointer.obj = (__bridge id)(*(void**)returnPtr);
            
            return jrPointer;
            
        }
          
        case JRTypeEncodeNodeTypeStruct:{
            
            NSValue* value = [NSValue valueWithBytes:returnPtr objCType:[returnNode.typeEncodeStr UTF8String]];
            
            JRPointer* jrPointer = [[JRPointer alloc]init];
            
            jrPointer.obj = value;
            
            return jrPointer;
        }
          
        case JRTypeEncodeNodeTypePointer:{
            
            JRPointer* jrPointer = [[JRPointer alloc]init];
            
            jrPointer.ptr = (*(void**)returnPtr);
            
            return jrPointer;

            
        }
        default:
            break;
    }
    
    return nil;
}

+(void)registerContext
{
    sharedContext[@"_log"] = ^(JRPointer* message){
        
        NSLog(@"%@",message);
        
    };
    
    sharedContext[@"_get_class_"] = ^(NSString* className){
        
        return [self getClass:className];
        
    };

    sharedContext[@"_encode_scalar_"]=^(NSString* encodeType,NSArray* value){
        
        //JRPointer* jrPointer = [JSRunner encodeScalarValue:encodeType value:value];
        
        JRPointer* jrPointer = [JSRunner packToStruct:encodeType values:value];
        
        return jrPointer;
        
    };


    sharedContext[@"_get_struct_member_"] = ^(NSString* structTypeEncode,JRPointer* structPointer,NSUInteger idx){
        
        return [JSRunner getValueFromStruct:structTypeEncode value:structPointer atIndex:idx];
        
    };
    
    sharedContext[@"_unpack_value_"] = ^(NSString* valueTypeEncode,JRPointer* valuePointer){
        
        return [self unpackValue:valueTypeEncode value:valuePointer];
        
    };
    
    //dynamic call objc functions
    
    sharedContext[@"_call_objc_method_"]=^(JRPointer* jrPointer,NSString* selectorString,NSArray* arguments){
        
        id obj = [jrPointer obj];
        
        SEL theSelector = NSSelectorFromString(selectorString);
        
        NSMethodSignature* methodSignature = [obj methodSignatureForSelector:theSelector];
        
        NSLog(@"%@ : %s",selectorString,[methodSignature methodReturnType]);
        
        id value = nil;
        
        NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        
        [invocation setTarget:obj];
        
        [invocation setSelector:theSelector];
        
        NSUInteger idx = 2;
        
        for(JRPointer* argument in arguments){
            
            if(![argument isKindOfClass:[jrPointer class]]){
                
                id voidArgument = argument;
                
                [invocation setArgument:&voidArgument atIndex:idx];
                
                continue;
            }
            
            void* weak_argument = (__bridge void*)argument.obj;
            
            if([argument.obj isKindOfClass:[JRValue class]] ){
                
                JRValue* jrValue = argument.obj;
                
                const char * type =  [methodSignature getArgumentTypeAtIndex:idx];
                
                NSMethodSignature* util = [NSMethodSignature signatureWithObjCTypes:[[NSString stringWithFormat:@"%s%s",type,@encode(void)]UTF8String]];
                
                void* value_ptr = malloc([util methodReturnLength]);
                
                [jrValue.value getValue:value_ptr];
                
                [invocation setArgument:value_ptr atIndex:idx];
                
            }else{
                
                [invocation setArgument:&weak_argument atIndex:idx];
                
            }
            
            idx++;
            
        }
        
        [invocation retainArguments];
        
        [invocation invoke];
        
        size_t returnSize = [methodSignature methodReturnLength];
        
        if( returnSize ){
            
            NSString* returnType = [NSString stringWithUTF8String:[methodSignature methodReturnType]];
            
            if ([returnType isEqualToString:@"@"]){
                
                void * tempValue = nil;
                
                [invocation getReturnValue:&tempValue];
                
                value = (__bridge id)tempValue;
                
            }else{
                
                void* returnPtr = malloc(returnSize);
                
                [invocation getReturnValue:returnPtr];
                
                NSValue* nsValue = [NSValue valueWithBytes:returnPtr objCType:[methodSignature methodReturnType]];
                
                JRValue* jrValue = [[JRValue alloc]init];
                
                jrValue.size = returnSize;
                
                jrValue.value = nsValue;
                
                value = jrValue;
            }
            
        }
        
        
        return [JRPointer JRPointerWithObj:value];
        
    };

}
-(id)init
{
    self = [super init];
    
    if(self){
        
        [self sharedContext];
        
        _jsFuncDic = [NSMutableDictionary dictionary];
        
        
    }
    
    return self;
}

-(void)registerJSFunction:(NSString *)jsContent forName:(NSString *)funcName
{
    _jsFuncDic[funcName] = jsContent;
}

-(void)executeJSFunction:(NSString *)name withArguments:(NSArray *)arguments
{
    NSString* jsContent = _jsFuncDic[name];
    
    [sharedContext evaluateScript:[NSString stringWithFormat: @"temp_func = %@",jsContent]];
    
    JSValue* func = sharedContext[@"temp_func"];
    
    [func callWithArguments:arguments];
    
    [sharedContext evaluateScript:@"delete temp_func"];
    
}


-(void)testBlock
{
//    sharedContext[@"testBlock"]=^(id obj){
//        
//        [sharedContext evaluateScript:@"_log('SUCCESS')"];
//        
//        return ;
//    };
//    
    NSString* jsPath = [[NSBundle mainBundle]pathForResource:@"block" ofType:@"js"];
    
    NSString* jsContent = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    
    [sharedContext evaluateScript:jsContent];
//
//    [sharedContext evaluateScript:@"delete testBlock"];
    
    
}
@end
