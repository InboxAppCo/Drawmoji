//
//  NSInputStream+Inbox.h
//  binaryProcessor
//
//  Created by Hani Shabsigh on 10/13/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInputStream (Inbox)

- (void)skip:(NSUInteger)maxLength;
- (Byte)readByte;
- (uint8_t)readInt8;
- (uint16_t)readInt16:(BOOL)bigEndian;
- (uint32_t)readInt32:(BOOL)bigEndian;
- (Float32)readFloat32:(BOOL)bigEndian;

@end
