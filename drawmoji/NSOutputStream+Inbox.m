//
//  NSOutputStream+Inbox.m
//  drawmoji
//
//  Created by Hani Shabsigh on 10/13/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

#import "NSOutputStream+Inbox.h"

@implementation NSOutputStream (Inbox)

- (void)writeByte:(Byte)value
{
    [self write:&value maxLength:1];
}

- (void)writeInt8:(uint8_t)value
{
    [self write:&value maxLength:1];
}

- (void)writeInt16:(uint16_t)value bigEndian:(BOOL)bigEndian
{
    if (bigEndian) {
        uint16_t newValue = CFSwapInt16BigToHost(value);
        [self write:(const uint8_t *)&newValue maxLength:2];
    } else {
        [self write:(const uint8_t *)&value maxLength:2];
    }
}

- (void)writeInt32:(uint32_t)value bigEndian:(BOOL)bigEndian
{
    if (bigEndian) {
        uint32_t newValue = CFSwapInt32BigToHost(value);
        [self write:(const uint8_t *)&newValue maxLength:4];
    } else {
        [self write:(const uint8_t *)&value maxLength:4];
    }
}

- (void)writeFloat:(Float32)value bigEndian:(BOOL)bigEndian
{
    if (bigEndian) {
        CFSwappedFloat32 swappedFloat = CFConvertFloat32HostToSwapped(value);
        [self write:(const uint8_t *)&swappedFloat maxLength:4];
    } else {
        [self write:(uint8_t *)&value maxLength:4];
    }
}

@end
