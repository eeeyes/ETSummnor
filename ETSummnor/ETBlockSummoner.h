//
//  ETBlockSummoner.h
//  XIBConverter
//
//  Created by chaoran on 16/5/18.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface ETBlockSummoner : NSObject

//!!! including the first block struct pointer

@property (nonatomic,strong) NSString* blockTypeEncode;

@property (nonatomic,strong) JSValue* jsFunction;

-(void*)generateBlockPtr;

@end
