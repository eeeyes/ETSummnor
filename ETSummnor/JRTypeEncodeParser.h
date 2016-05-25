//
//  JRTypeEncodeParser.h
//  XIBConverter
//
//  Created by chaoran on 16/5/9.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "ffi.h"

typedef enum
{
    JRTypeEncodeNodeTypeNone,
    
    JRTypeEncodeNodeTypeElement,
    
    //cislq
    
    JRTypeEncodeNodeTypeChar,
    
    JRTypeEncodeNodeTypeInt,
    
    JRTypeEncodeNodeTypeShort,
    
    JRTypeEncodeNodeTypeLong,
    
    JRTypeEncodeNodeTypeLongLong,
    
    //CISLQ
    
    JRTypeEncodeNodeTypeUnsignedChar,
    
    JRTypeEncodeNodeTypeUnsignedInt,
    
    JRTypeEncodeNodeTypeUnsignedShort,
    
    JRTypeEncodeNodeTypeUnsignedLong,
    
    JRTypeEncodeNodeTypeUnsignedLongLong,
    
    //fd
    
    JRTypeEncodeNodeTypeFloat,
    
    JRTypeEncodeNodeTypeDouble,
    
    //Bv*#@
    
    JRTypeEncodeNodeTypeBool,
    
    JRTypeEncodeNodeTypeVoid,
    
    JRTypeEncodeNodeTypeCharPointer,
    
    JRTypeEncodeNodeTypeClassObj,
    
    JRTypeEncodeNodeTypeObj,
    
    //^ {}
    
    JRTypeEncodeNodeTypePointer,
    
    JRTypeEncodeNodeTypeStruct
    
}JRTypeEncodeNodeType;

@interface JRTypeEncodeNode : NSObject

@property (nonatomic,assign) JRTypeEncodeNodeType nodeType;

@property (nonatomic,strong) NSString* typeEncodeStr;

@property (nonatomic,strong,readonly) NSMutableArray* childNodes;

@property (nonatomic,assign) NSUInteger mem_start_offset;

@property (nonatomic,assign) NSUInteger mem_size;

-(void)caculateMemOffset;

-(ffi_type*)ffiType;

-(void)freeFFiType:(ffi_type*)ffiType;



+(NSString*)CGFloatEncode;

+(NSString*)NSIntegerEncode;

+(NSString*)NSUIntegerEncode;

-(size_t)size;

-(void)copyValue:(id)argument toPtr:(void*)dstPtr;

-(id)copyPtrToValue:(void*)srcPtr;

@end

@interface JRTypeEncodeParser : NSObject

@property (nonatomic,strong) NSString* typeEncodeStr;

-(JRTypeEncodeNode*)startParse;

-(JRTypeEncodeNode*)tryParseGoalStatement;


@end
