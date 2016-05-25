//
//  ETBlockSummoner.m
//  XIBConverter
//
//  Created by chaoran on 16/5/18.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import "ETBlockSummoner.h"

#import "ffi.h"

#import "JRTypeEncodeParser.h"

#import "ETJSSummoner.h"



@interface ETBlockSummoner()
{
    ffi_cif* cif_ptr;
    
    ffi_type **args;
    
    ffi_closure *closure;
    
    BOOL hasGenerated;
    
    void* blockPtr;
}

@property (nonatomic,strong) JRTypeEncodeNode* blockEncodeNode;
@property (nonatomic,strong) JSContext* jsContext;
@end

struct ETSummonerBlock {
    void *isa;
    int flags;
    int reserved;
    void* invoke;
    struct ETSummonerBlockDescriptor *descriptor;
};

static struct ETSummonerBlockDescriptor {
    unsigned long int reserved;
    unsigned long int Block_size;
} summonerBlockDescriptor = { 0, sizeof(struct ETSummonerBlock) };

void summonerBlockInterpreter(ffi_cif* cif,void*ret,void**args,void*userdata)
{
    ETBlockSummoner* summonerBlock = (__bridge ETBlockSummoner*)userdata;
    
    JRTypeEncodeNode* arrayNode = summonerBlock.blockEncodeNode;
    
    JRTypeEncodeNode* returnNode = arrayNode.childNodes.firstObject;
    
    NSUInteger argumentCount = [arrayNode.childNodes count] - 1 ;
    
    NSMutableArray* jsArgumentArray = [NSMutableArray array];
    
    for(int i = 1 ; i < argumentCount ; i++){
        
        JRTypeEncodeNode* node = arrayNode.childNodes[i+1];
        
        void* argumentPtr = args[i];
        
        id value = [node copyPtrToValue:argumentPtr];
        
        [jsArgumentArray addObject:value];
        
    }
    
    id jsResult = [[summonerBlock.jsFunction callWithArguments:jsArgumentArray]toObject];
    
    [returnNode copyValue:jsResult toPtr:ret];
  
}



@implementation ETBlockSummoner
-(id)init
{
    self = [super init];
    
    if(self){
        
        hasGenerated = NO;
        
    }
    
    return self;
}
-(void*)generateBlockPtr
{
    if(hasGenerated){
        
        return blockPtr;
        
    }
    
    hasGenerated = YES;
    
    JRTypeEncodeParser* encodeParser = [[JRTypeEncodeParser alloc]init];
    
    encodeParser.typeEncodeStr = self.blockTypeEncode;
    
    JRTypeEncodeNode* arrayNode = [encodeParser startParse];
    
    self.blockEncodeNode = arrayNode;
    
    JRTypeEncodeNode* returnNode = arrayNode.childNodes.firstObject;
    
    ffi_type* returnType = [returnNode ffiType];
    
    NSUInteger argumentCount = [arrayNode.childNodes count] - 1;
    
    cif_ptr = malloc(sizeof(ffi_cif));
    
    void* blockImp = NULL;
    
    args = malloc(sizeof(ffi_type*) * argumentCount) ;
    
    for(int i = 0 ; i < argumentCount ; i++){
        
        JRTypeEncodeNode* currentNode = arrayNode.childNodes[i+1];
        
        ffi_type* current_ffi_type = [currentNode ffiType];
        
        args[i] = current_ffi_type;
        
    }
    
    
    
    closure = ffi_closure_alloc(sizeof(ffi_closure), (void**)&blockImp);
    
    if(ffi_prep_cif(cif_ptr, FFI_DEFAULT_ABI, (unsigned int)argumentCount,returnType, args)==FFI_OK){
        
        if (ffi_prep_closure_loc(closure, cif_ptr, summonerBlockInterpreter,
                                 (__bridge void*)self, blockImp) == FFI_OK)
        {
            
            
        }
        
    }
    
    [returnNode freeFFiType:returnType];
    
    
    struct ETSummonerBlock summonerBlock = {
        &_NSConcreteStackBlock,
        (1<<29), 0,
        blockImp,
        &summonerBlockDescriptor
    };

    
    blockPtr = malloc(sizeof(struct ETSummonerBlock));
    
    memcpy(blockPtr, &summonerBlock, sizeof(struct ETSummonerBlock));
   
    return blockPtr;
}

-(void)dealloc
{
    ffi_closure_free(closure);
    
    free(args);
    
    free(cif_ptr);
    
    free(blockPtr);
    
    return;
}
@end
