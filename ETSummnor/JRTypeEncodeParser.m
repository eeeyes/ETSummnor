//
//  JRTypeEncodeParser.m
//  XIBConverter
//
//  Created by chaoran on 16/5/9.
//  Copyright © 2016年 chaoran. All rights reserved.
//

//parser table

/**

 goal -> type+
 
 type -> { id+ = type+ }
 
 type -> ^type
 
 type -> e
 
 
*/


#import "JRTypeEncodeParser.h"

#import "ETBlockSummoner.h"

#define JRALIGN(v, a)  (((((size_t) (v))-1) | ((a)-1))+1)

#import <UIKit/UIKit.h>

#import "JSRunner.h"

@implementation JRTypeEncodeNode

-(id)init
{
    self = [super init];
    
    if(self){
        
        _childNodes = [NSMutableArray array];
        
        _nodeType = JRTypeEncodeNodeTypeNone;
        
    }
    
    return self;

}
+(NSString*)CGFloatEncode
{
    return [NSString stringWithUTF8String: @encode(CGFloat) ];
}

+(NSString*)NSIntegerEncode
{
    return [NSString stringWithUTF8String:@encode(NSInteger)];
}
+(NSString*)NSUIntegerEncode
{
    return [NSString stringWithUTF8String:@encode(NSUInteger)];
}
-(ffi_type*)ffiType
{

    switch (_nodeType) {
            
        case JRTypeEncodeNodeTypeChar:{
            
            return &ffi_type_schar;
    
        }
         
        case JRTypeEncodeNodeTypeShort:{
            
            return &ffi_type_sshort;
        }
            
        case JRTypeEncodeNodeTypeInt:{
            
            return &ffi_type_sint;
            
        }
        case JRTypeEncodeNodeTypeLong:{
            
            return &ffi_type_slong;
            
        }
            
        case JRTypeEncodeNodeTypeLongLong:{
            
            return &ffi_type_sint64;
        }
            
            
        case JRTypeEncodeNodeTypeUnsignedChar:{
            
            return &ffi_type_uchar;
            
        }
            
        case JRTypeEncodeNodeTypeUnsignedShort:{
            
            return &ffi_type_ushort;
            
        }
            
        case JRTypeEncodeNodeTypeUnsignedInt:{
            
            return &ffi_type_uint;
        }
            
        case JRTypeEncodeNodeTypeUnsignedLong:{
            
            return &ffi_type_ulong;
        }
            
        case JRTypeEncodeNodeTypeUnsignedLongLong:{
            
            return &ffi_type_uint64;
            
        }
            
        case JRTypeEncodeNodeTypeFloat:{
            
            return &ffi_type_float;
            
        }
            
        case JRTypeEncodeNodeTypeDouble:{
            
            return &ffi_type_double;
            
        }
            
        case JRTypeEncodeNodeTypeBool:{
            
            return &ffi_type_uint8;
            
        }
            
        case JRTypeEncodeNodeTypeVoid:{
            
            return &ffi_type_void;
            
        }
            
        case JRTypeEncodeNodeTypePointer:
        case JRTypeEncodeNodeTypeCharPointer:
        case JRTypeEncodeNodeTypeClassObj:
        case JRTypeEncodeNodeTypeObj:{
            
            return &ffi_type_pointer;
            
        }
            
        case JRTypeEncodeNodeTypeStruct:{
            
            NSUInteger element_count = [self.childNodes count];
            
            
            ffi_type** ffi_type_struct_element = malloc(sizeof(ffi_type*) * (element_count + 1));
            
            for(int idx = 0 ; idx < element_count ; idx++){
                
                JRTypeEncodeNode* childNode = self.childNodes[idx];
                
                ffi_type_struct_element[idx] = [childNode ffiType];
                
            }
            
            ffi_type_struct_element[element_count] = NULL;
            
            
            ffi_type* ffi_type_struct_ptr = malloc(sizeof(ffi_type));
        
            ffi_type_struct_ptr->size = 0;
            
            ffi_type_struct_ptr->alignment = 0;
            
            ffi_type_struct_ptr->type = FFI_TYPE_STRUCT;
            
            ffi_type_struct_ptr-> elements = ffi_type_struct_element;
            
            return ffi_type_struct_ptr;
            
           
            
        }
            
        default:
            break;
    }
    
    return &ffi_type_void;
}
-(void)freeFFiType:(ffi_type *)ffiType
{
    if(ffiType->type != FFI_TYPE_STRUCT){
        
        return;
        
    }
    
    ffi_type** element = ffiType->elements;
    
    NSUInteger elementCount = [self.childNodes count];
    
    for(int idx = 0 ; idx < elementCount ; idx ++){
        
        JRTypeEncodeNode* childNode = self.childNodes[idx];
        
        [childNode freeFFiType:element[idx]];
        
    }
    
    free(element);
    
    free(ffiType);
    
}
-(size_t)size
{
    return self.mem_size;
    
}

-(void)copyValue:(id)argument toPtr:(void *)destPtr
{
    switch (self.nodeType) {
            
        case JRTypeEncodeNodeTypeChar:{
            
            NSNumber* current_argument = argument;
            
            char* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument charValue];
        
            break;
        }
            
        case JRTypeEncodeNodeTypeShort:{
            
            NSNumber* current_argument = argument;
            
            short* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument shortValue];
        
            break;
            
        }
            
        case JRTypeEncodeNodeTypeInt:{
            
            NSNumber* current_argument = argument;
            
            int* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument intValue];
            
            break;
            
        }
            
        case JRTypeEncodeNodeTypeLong:{
            
            NSNumber* current_argument = argument;
            
            long* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument longValue];
            
            break;
        }
            
        case JRTypeEncodeNodeTypeLongLong:{
            
            NSNumber* current_argument = argument;
            
            long long* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument longLongValue];
            
            break;
        }
            
        case JRTypeEncodeNodeTypeUnsignedChar:{
            
            NSNumber* current_argument = argument;
            
            unsigned char* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument unsignedCharValue];
            
            break;
        }
            
        case JRTypeEncodeNodeTypeUnsignedShort:{
            
            NSNumber* current_argument = argument;
            
            unsigned short* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument unsignedShortValue];
            
            break;
            
        }
            
        case JRTypeEncodeNodeTypeUnsignedInt:{
            
            NSNumber* current_argument = argument;
            
            unsigned int* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument unsignedIntValue];
            
            break;
        }
            
        case JRTypeEncodeNodeTypeUnsignedLong:{
            
            NSNumber* current_argument = argument;
            
            unsigned long* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument unsignedLongValue];
            
            break;
        }
            
        case JRTypeEncodeNodeTypeUnsignedLongLong:{
            
            NSNumber* current_argument = argument;
            
            unsigned long long* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument unsignedLongLongValue];
            
            break;
        }
            
        case JRTypeEncodeNodeTypeFloat:{
            
            NSNumber* current_argument = argument;
            
            float* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument floatValue];
            
            break;;
        }
            
        case JRTypeEncodeNodeTypeDouble:{
            
            NSNumber* current_argument = argument;
            
            double* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument doubleValue];
        
            break;
        }
            
        case JRTypeEncodeNodeTypeBool:{
            
            NSNumber* current_argument = argument;
            
            BOOL* current_argument_value_ptr = destPtr;
            
            *current_argument_value_ptr = [current_argument boolValue];
            
            break;
        }
            
        case JRTypeEncodeNodeTypeVoid:{
            
            break;
        }
            
        case JRTypeEncodeNodeTypeCharPointer:{
            
            if([argument isKindOfClass:[JRPointer class]]){
                
                JRPointer* current_argument = argument;
                
                void* ptr = current_argument.ptr;
                
                void** ptr_ptr = destPtr;
                
                *ptr_ptr = ptr;
                
                break;
            }
            
            if([argument isKindOfClass:[NSString class]]){
                
                NSString* current_argument = argument;
                
                const char* ptr = [current_argument UTF8String];
                
                const char** ptr_ptr = destPtr;
                
                *ptr_ptr = ptr;
              
                break;
            }
        }
            
        case JRTypeEncodeNodeTypeClassObj:{
            
            JRPointer* current_argument = argument;
            
            id ptr = current_argument.obj;
            
            void** ptr_ptr = destPtr;
            
            *ptr_ptr = (__bridge void *)(ptr);
            
            break;
            
        }
        case JRTypeEncodeNodeTypeObj:{
            
            if([argument isKindOfClass:[JRPointer class]]){
                
                JRPointer* current_argument = argument;
                
                if(!current_argument.isBlock){
                    
                    id ptr = current_argument.obj;
                    
                    void** ptr_ptr = destPtr;
                    
                    *ptr_ptr = (__bridge void *)(ptr);
                    
                }else{
                    
                    ETBlockSummoner* blockSummoner = current_argument.obj;
                    
                    void** ptr_ptr = destPtr;
                    
                    *ptr_ptr = [blockSummoner generateBlockPtr];
                    
                }
                
                break;
            }
            
            if([argument isKindOfClass:[NSString class]] || [argument isKindOfClass:[NSNumber class]] || [argument isKindOfClass:[NSArray class]] || [argument isKindOfClass:[NSDictionary class]]  ){
                
                id ptr = argument;
                
                void** ptr_ptr = destPtr;
                
                *ptr_ptr = (__bridge void *)(ptr);
                
                break;
                
            }
            
            break;
        }
            
        case JRTypeEncodeNodeTypeStruct:{
            
            JRPointer* current_argument = argument;
            
            NSValue* current_argument_value = current_argument.obj;
            
            void* value_ptr = destPtr;
            
            [current_argument_value getValue:value_ptr];
            
            break;
        }
            
        case JRTypeEncodeNodeTypePointer:{
            
            if([argument isKindOfClass:[NSString class]]){
                
                NSString* current_argument = argument;
                
                const char* ptr = [current_argument UTF8String];
                
                const char** ptr_ptr = destPtr;
                
                *ptr_ptr = ptr;
                
                break;
            }
            
            JRPointer* current_argument = argument;
            
            void* ptr = current_argument.ptr;
            
            void** value_ptr = destPtr;
            
            *value_ptr = ptr;
            
            break;
        }
            
        default:
            break;
    }

}
-(id)copyPtrToValue:(void *)srcPtr
{
    switch (self.nodeType) {
            
        case JRTypeEncodeNodeTypeChar:{
            
            char returnValue = *(char*)srcPtr;
            
            return [NSNumber numberWithChar:returnValue];
            
        }
            
            
        case JRTypeEncodeNodeTypeShort:{
            
            short returnValue = *(short*)srcPtr;
            
            return [NSNumber numberWithShort:returnValue];
            
        }
            
        case JRTypeEncodeNodeTypeInt:{
            
            int returnValue = *(int*)srcPtr;
            
            return [NSNumber numberWithInt:returnValue];
            
        }
            
        case JRTypeEncodeNodeTypeLong:{
            
            long returnValue = *(long*)srcPtr;
            
            return [NSNumber numberWithLong:returnValue];
            
        }
            
        case JRTypeEncodeNodeTypeLongLong:{
            
            long long returnValue = *(long long*)srcPtr;
            
            return [NSNumber numberWithLongLong:returnValue];
        }
            
            //
            
        case JRTypeEncodeNodeTypeUnsignedChar:{
            
            unsigned char returnValue = *(unsigned char*)srcPtr;
            
            return [NSNumber numberWithUnsignedChar:returnValue];
            
        }
            
        case JRTypeEncodeNodeTypeUnsignedShort:{
            
            unsigned short returnValue = *(unsigned short*)srcPtr;
            
            return [NSNumber numberWithUnsignedShort:returnValue];
            
        }
            
        case JRTypeEncodeNodeTypeUnsignedInt:{
            
            unsigned int returnValue = *(unsigned int*)srcPtr;
            
            return [NSNumber numberWithUnsignedInt:returnValue];
        }
            
        case JRTypeEncodeNodeTypeUnsignedLong:{
            
            unsigned long returnValue = *(unsigned long*)srcPtr;
            
            return [NSNumber numberWithUnsignedLong:returnValue];
            
        }
            
        case JRTypeEncodeNodeTypeUnsignedLongLong:{
            
            unsigned long long returnValue = *(unsigned long long*)srcPtr;
            
            return [NSNumber numberWithUnsignedLongLong:returnValue];
            
        }
            
            //
        case JRTypeEncodeNodeTypeFloat:{
            
            float returnValue = *(float*)srcPtr;
            
            return [NSNumber numberWithFloat: returnValue];
        }
            
        case JRTypeEncodeNodeTypeDouble:{
            
            double returnValue = *(double*)srcPtr;
            
            return [NSNumber numberWithDouble:returnValue];
            
        }
        case JRTypeEncodeNodeTypeBool:{
            
            BOOL returnValue = *(BOOL*)srcPtr;
            
            return [NSNumber numberWithBool:returnValue];
            
        }
            
        case JRTypeEncodeNodeTypeVoid:{
            
            return NULL;
        }
            
        case JRTypeEncodeNodeTypeCharPointer:{
            
            JRPointer* jrPointer = [[JRPointer alloc]init];
            
            jrPointer.ptr = *(char**)srcPtr;
            
            return jrPointer;
            
        }
            
        case JRTypeEncodeNodeTypeClassObj:
        case JRTypeEncodeNodeTypeObj:{
            
            JRPointer* jrPointer = [[JRPointer alloc]init];
            
            jrPointer.obj = (__bridge id)(*(void**)srcPtr);
            
            return jrPointer;
            
        }
            
        case JRTypeEncodeNodeTypeStruct:{
            
            NSValue* value = [NSValue valueWithBytes:srcPtr objCType:[self.typeEncodeStr UTF8String]];
            
            JRPointer* jrPointer = [[JRPointer alloc]init];
            
            jrPointer.obj = value;
            
            return jrPointer;
        }
            
        case JRTypeEncodeNodeTypePointer:{
            
            JRPointer* jrPointer = [[JRPointer alloc]init];
            
            jrPointer.ptr = (*(void**)srcPtr);
            
            return jrPointer;
            
            
        }
            
        default:
            break;
    }
    
    return nil;
}
-(void)caculateMemOffset:(size_t*)mem_start_offset_ptr align:(size_t*)align
{
    JRTypeEncodeNodeType nodeType = self.nodeType;
    
    size_t mem_start_offset = *mem_start_offset_ptr;
    
    if(nodeType == JRTypeEncodeNodeTypeVoid){
        
        self.mem_start_offset = mem_start_offset ;
        
        self.mem_size = 0;
        
        return;
        
    }
    
    
    if(nodeType != JRTypeEncodeNodeTypeStruct){
        
        ffi_type* a_ffi_type = [self ffiType];
        
        size_t new_mem_start = mem_start_offset;
        
        new_mem_start = JRALIGN(new_mem_start, a_ffi_type->alignment);
       
        self.mem_start_offset = new_mem_start;
        
        self.mem_size = a_ffi_type->size;
        
        *mem_start_offset_ptr = new_mem_start + self.mem_size ;
        
        if(a_ffi_type->alignment > *align ){
            
            *align = a_ffi_type -> alignment;
            
        }
        
        return;
        
    }
    
    size_t new_mem_start = mem_start_offset;
    
    for(JRTypeEncodeNode* childNode in self.childNodes){
        
        [childNode caculateMemOffset:mem_start_offset_ptr align:align];
        
    }
    
    new_mem_start = JRALIGN(new_mem_start, *align);
    
    self.mem_start_offset = new_mem_start;
    
    size_t size = *mem_start_offset_ptr - new_mem_start;
    
    self.mem_size = JRALIGN(size , *align);
    
    
}
-(void)caculateMemOffset
{
    size_t mem_start_offset = 0;
    
    size_t max_align = 0;
    
    [self caculateMemOffset:&mem_start_offset align:&max_align];
    
}
@end

@interface JRTypeEncodeParser()
{
    //caculate mem offset
    
    NSUInteger _current_mem_offset ;
    
    NSString* _currentStructEncode ;
    
    
    //map from type encode to element type
    
    NSString* _validTypeEncode;
    
    NSArray* _elementType;
}

@end

@implementation JRTypeEncodeParser

-(id)init
{
    self = [super init];
    
    if(self){
        
        _validTypeEncode = @"cislqCISLQfdBv*#@:";
        
        _elementType = @[@(JRTypeEncodeNodeTypeChar),@(JRTypeEncodeNodeTypeInt),@(JRTypeEncodeNodeTypeShort),@(JRTypeEncodeNodeTypeLong),@(JRTypeEncodeNodeTypeLongLong),
                         
                         @(JRTypeEncodeNodeTypeUnsignedChar),@(JRTypeEncodeNodeTypeUnsignedInt),@(JRTypeEncodeNodeTypeUnsignedShort),@(JRTypeEncodeNodeTypeUnsignedLong),@(JRTypeEncodeNodeTypeUnsignedLongLong),
                         
                         @(JRTypeEncodeNodeTypeFloat),@(JRTypeEncodeNodeTypeDouble),@(JRTypeEncodeNodeTypeBool),@(JRTypeEncodeNodeTypeVoid),
                         
                         @(JRTypeEncodeNodeTypeCharPointer),@(JRTypeEncodeNodeTypeClassObj),@(JRTypeEncodeNodeTypeObj),@(JRTypeEncodeNodeTypePointer)];
        
        
        _current_mem_offset = 0;
        
        _currentStructEncode = nil;
        
    }
    
    return self;
}
-(JRTypeEncodeNode*)tryParseGoalStatement
{
    JRTypeEncodeNode* arrayNode = [[JRTypeEncodeNode alloc]init];
    
    NSUInteger parseStartIndex = 0;
    
    NSUInteger totalLength = [self.typeEncodeStr length];
    
    NSUInteger currentEndIdx = 0;
    
    BOOL parseSuccess = YES;
    
    while (parseStartIndex < totalLength) {
    
        JRTypeEncodeNode* childNode = nil;
        
        childNode = [self tryParseTypeStatementAtStartIdx:parseStartIndex endIdx:&currentEndIdx];
        
        if(!childNode){
            
            parseSuccess = NO;
            
            break;
        }
        
        parseStartIndex = currentEndIdx+1;
        
        [arrayNode.childNodes addObject:childNode];
    }
    
    if(parseSuccess){
        
        return arrayNode;
        
    }
    
    return nil;
}

-(JRTypeEncodeNode*)tryParseTypeStatementAtStartIdx:(NSUInteger)startIdx endIdx:(NSUInteger*)endIdxPtr
{
   
    JRTypeEncodeNode* typeNode = nil;
    
    typeNode = [self tryParsePointerStatementAtStartIdx:startIdx endIdx:endIdxPtr];
    
    if(typeNode){
        
        return typeNode;
    }
    
    typeNode = [self tryParseStructStatementAtStartIdx:startIdx endIdx:endIdxPtr];
    
    if(typeNode){
        
        return typeNode;
    }
    
    typeNode = [self tryParseBlockStatementAtStartIdx:startIdx endIdx:endIdxPtr];
    
    if(typeNode){
        
        return typeNode;
        
    }
    
    typeNode = [self tryParseElementStatementAtStartIdx:startIdx endIdx:endIdxPtr];
    
    if(typeNode){
        
        return typeNode;
        
    }
    
    return typeNode;
}
-(BOOL)tryParseIDStatementAtStartIdx:(NSUInteger)startIdx endIdx:(NSUInteger*)endIdxPtr
{
    NSUInteger totalLength = [self.typeEncodeStr length];
    
    if(startIdx >= totalLength){
        
        return NO;
        
    }
    
    char* bytes = (char*)[self.typeEncodeStr UTF8String];
    
    char current_char = bytes[startIdx];
    
    if(current_char == '{' || current_char == '}' || current_char == '=' ){
        
        return NO;
    }
    
    *endIdxPtr = startIdx;
    
    return YES;
}
-(JRTypeEncodeNode*)tryParsePointerStatementAtStartIdx:(NSUInteger)startIdx endIdx:(NSUInteger*)endIdxPtr
{
    NSUInteger totalLength = [self.typeEncodeStr length];
    
    if(startIdx >= totalLength){
        
        return nil;
        
    }

    char* bytes = (char*)[self.typeEncodeStr UTF8String];
    
    char current_char = bytes[startIdx];
    
    if(current_char != '^' ){
        
        return nil;
    
    }
    
    
    JRTypeEncodeNode* childNode = [self tryParseTypeStatementAtStartIdx:startIdx+1 endIdx:endIdxPtr];
    
    if(!childNode){
        
        return nil;
    }
    
    JRTypeEncodeNode* pointerNode = [[JRTypeEncodeNode alloc]init];
    
    pointerNode.typeEncodeStr = [self.typeEncodeStr substringWithRange:NSMakeRange(startIdx, *endIdxPtr-startIdx+1)];
    
    pointerNode.nodeType = JRTypeEncodeNodeTypePointer;
    
    [pointerNode.childNodes addObject:childNode];
    
    return pointerNode;
}
-(JRTypeEncodeNode*)tryParseBlockStatementAtStartIdx:(NSUInteger)startIdx endIdx:(NSUInteger*)endIdxPtr
{
    NSUInteger totalLength = [self.typeEncodeStr length];
    
    if(startIdx+1 >= totalLength){
        
        return nil;
        
    }
    
    char* bytes = (char*)[self.typeEncodeStr UTF8String];
    
    char current_char = bytes[startIdx];
    
    char next_char = bytes[startIdx+1];
    
    if(current_char != '@'  || next_char != '?' ){
        
        return nil;
        
    }
    
   
    *endIdxPtr = startIdx + 1;
    
    JRTypeEncodeNode* pointerNode = [[JRTypeEncodeNode alloc]init];
    
    pointerNode.typeEncodeStr = [self.typeEncodeStr substringWithRange:NSMakeRange(startIdx, *endIdxPtr-startIdx+1)];
    
    pointerNode.nodeType = JRTypeEncodeNodeTypeObj;
    
    return pointerNode;
}
-(JRTypeEncodeNode*)tryParseElementStatementAtStartIdx:(NSUInteger)startIdx endIdx:(NSUInteger*)endIdxPtr
{
    NSUInteger totalLength = [self.typeEncodeStr length];
    
    if(startIdx >= totalLength){
        
        return nil;
        
    }
    
    char* bytes = (char*)[self.typeEncodeStr UTF8String];
    
    char current_char = bytes[startIdx];
    
    char* valid_element = (char*)[_validTypeEncode UTF8String];
    
    BOOL parseSuccess = NO;
    
    JRTypeEncodeNodeType nodetype = JRTypeEncodeNodeTypeNone;
    
    for(int i = 0 ; i < [_validTypeEncode length] ; i++){
        
        if(current_char == valid_element[i]){
            
            parseSuccess = YES;
            
            *endIdxPtr = startIdx;
            
            nodetype = (JRTypeEncodeNodeType)[_elementType[i]unsignedIntegerValue];
            
            break;
        }
        
    }

    
    if(!parseSuccess){
    
        return nil;
        
    }
    
    JRTypeEncodeNode* elementNode = [[JRTypeEncodeNode alloc]init];
    
    elementNode.typeEncodeStr = [self.typeEncodeStr substringWithRange:NSMakeRange(startIdx, 1)];
    
    elementNode.nodeType = nodetype;
    
    return elementNode;
    

}
-(JRTypeEncodeNode*)tryParseStructStatementAtStartIdx:(NSUInteger)startIdx endIdx:(NSUInteger*)endIdxPtr
{
    JRTypeEncodeNode* structNode = [[JRTypeEncodeNode alloc]init];
    
    structNode.nodeType = JRTypeEncodeNodeTypeStruct;
    
    NSUInteger totalLength = [self.typeEncodeStr length];
    
    NSUInteger cacheStartIdx = startIdx;
    
    if(startIdx >= totalLength){
        
        return nil;
        
    }
    
    char* bytes = (char*)[self.typeEncodeStr UTF8String];
    
    char current_char = bytes[startIdx];
    
    if(current_char!='{'){
        
        return nil;
    }
    
    startIdx = startIdx + 1;
    
    while(true){
        
        if( ![self tryParseIDStatementAtStartIdx:startIdx endIdx:endIdxPtr] ){
        
            break;
        
        }
        
        startIdx = (*endIdxPtr) + 1;
        
    }
    
    if(startIdx >= totalLength){
        
        return nil;
        
    }

    if(bytes[startIdx]!='='){
        
        return nil;
    }
    
    startIdx = startIdx + 1;
    
    while (true) {
        
        JRTypeEncodeNode* childNode = nil;
        
        if((childNode = [self tryParseTypeStatementAtStartIdx:startIdx endIdx:endIdxPtr])==nil){
            
            break;
        }
        
        startIdx = (*endIdxPtr) + 1;

        [structNode.childNodes addObject:childNode];
    }
    
    
    if(startIdx >= totalLength){
        
        return nil;
        
    }
    
    if(bytes[startIdx]!='}'){
        
        return nil;
    }
    
    structNode.typeEncodeStr = [self.typeEncodeStr substringWithRange:NSMakeRange(cacheStartIdx, startIdx - cacheStartIdx+1)];
    
    *endIdxPtr = startIdx;
    
    return structNode;
}

-(JRTypeEncodeNode*)startParse
{
    JRTypeEncodeNode* globalNode = [self tryParseGoalStatement];
    
    for(JRTypeEncodeNode* childNode in globalNode.childNodes){
        
        [childNode caculateMemOffset];
        
    }
    
    return globalNode;
    
}


@end
