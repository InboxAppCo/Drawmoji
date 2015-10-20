//
//  NSInputStream+Inbox.m
//  binaryProcessor
//
//  Created by Hani Shabsigh on 10/13/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

#import "endian.h"

#import "NSInputStream+Inbox.h"

@implementation NSInputStream (Inbox)

- (Byte)readByte
{
    Byte value = 0;
    
    if ([self read:(uint8_t *)&value maxLength:1] != 1)
    {
        NSLog(@"***** Couldn't read Byte");
    }
    
    return value;
}

- (uint8_t)readInt8
{
    uint8_t value = 0;
    
    if ([self read:(uint8_t *)&value maxLength:1] != 1)
    {
        NSLog(@"***** Couldn't read int8");
    }
    
    return value;
}

- (uint16_t)readInt16:(BOOL)bigEndian
{
    uint16_t value = 0;
    
    if ([self read:(uint8_t *)&value maxLength:2] != 2)
    {
        NSLog(@"***** Couldn't read int16");
    }
    
    if (bigEndian) {
        return CFSwapInt16HostToBig(value);
    } else {
        return value;
    }
}

- (uint32_t)readInt32:(BOOL)bigEndian
{
    uint32_t value = 0;
    
    if ([self read:(uint8_t *)&value maxLength:4] != 4)
    {
        NSLog(@"***** Couldn't read int32");
    }
    
    if (bigEndian) {
        return CFSwapInt32HostToBig(value);
    } else {
        return value;
    }
}

- (Float32)readFloat32:(BOOL)bigEndian
{
    if (bigEndian) {
        CFSwappedFloat32 value;
        
        if ([self read:(uint8_t *)&value maxLength:4] != 4)
        {
            NSLog(@"***** Couldn't read float");
        }
        
        return CFConvertFloat32SwappedToHost(value);
    } else {
        float_t value = 0.0;
        
        if ([self read:(uint8_t *)&value maxLength:4] != 4)
        {
            NSLog(@"***** Couldn't read float");
        }
        
        return value;
    }
}

@end
