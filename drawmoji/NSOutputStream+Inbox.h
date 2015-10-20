//
//  NSOutputStream+Inbox.h
//  drawmoji
//
//  Created by Hani Shabsigh on 10/13/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOutputStream (Inbox)

- (void)writeByte:(Byte)value;
- (void)writeInt8:(uint8_t)value;
- (void)writeInt16:(uint16_t)value bigEndian:(BOOL)bigEndian;
- (void)writeInt32:(uint32_t)value bigEndian:(BOOL)bigEndian;
- (void)writeFloat:(Float32)value bigEndian:(BOOL)bigEndian;

@end
