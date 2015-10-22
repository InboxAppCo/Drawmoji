//
//  DrawingBinaryProcessor.m
//  binaryProcessor
//
//  Created by Hani Shabsigh on 10/13/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

#import "DrawingBinaryProcessor.h"
#import "NSInputStream+Inbox.h"
#import "NSOutputStream+Inbox.h"
#import "drawmoji-Swift.h"

static int const ENCODING_VERSION = 1;
static int const MAGIC_NUMBER = 0xF0E1D2C3;
static int const HEADER_LENGTH = 10;
static int const LINE_HEADER_LENGTH = 8;
//static Byte const NO_MORE_LINES = 0x0;
static Byte const ANOTHER_LINE  = 0xF;

@implementation DrawingBinaryProcessor

+ (Drawing *)decodeDrawingFromData:(NSData *)data {
    Drawing *drawing = [[Drawing alloc] init];
    
    NSInputStream *inputStream = [[NSInputStream alloc] initWithData:data];
    [inputStream open];
    
    if ([inputStream readInt32:true] != MAGIC_NUMBER) {
        return nil;
    }
    
    if ([inputStream readInt16:true] != ENCODING_VERSION) {
        return nil;
    }
    
    int headerLength = [inputStream readInt16:true];
    int lineHeaderLength = [inputStream readInt16:true];
    
    drawing.width = [inputStream readInt16:true];
    drawing.height = [inputStream readInt16:true];
    
    BOOL containsBackground = ([inputStream readInt16:true] == 1)?true:false;
    
    int backgroundImageLength = 0;
    if (containsBackground) {
        backgroundImageLength = [inputStream readInt32:true];
    } else {
        [inputStream skip:4];
    }
    
    if (headerLength > HEADER_LENGTH) {
        [inputStream skip:headerLength-HEADER_LENGTH];
    }
    
    Byte endFlag = [inputStream readByte];
    while (endFlag == ANOTHER_LINE) {
        int pointCount = [inputStream readInt32:true];
        
        Line *line = [[Line alloc] init];
        
        line.brushType = [inputStream readInt16:true];
        line.lineWidth = [inputStream readInt32:true];
        
        int aInt = [inputStream readInt8];
        int rInt = [inputStream readInt8];
        int gInt = [inputStream readInt8];
        int bInt = [inputStream readInt8];
        float a = aInt/255.0f;
        float r = rInt/255.0f;
        float g = gInt/255.0f;
        float b = bInt/255.0f;
        line.color = [UIColor colorWithRed:r green:g blue:b alpha:a];
        
        if (lineHeaderLength > LINE_HEADER_LENGTH) {
            [inputStream skip:lineHeaderLength-LINE_HEADER_LENGTH];
        }
        
        float x = 0;
        float y = 0;
        for (int i = 0; i < pointCount; i++) {
            x = [inputStream readFloat32:true];
            y = [inputStream readFloat32:true];
            [line addPointAtLocation:CGPointMake(x, y)];
        }
        
        if ([line getPointCount] != 0) {
            [drawing addLine:line];
        }
        
        endFlag = [inputStream readByte];
    }
    
    if (containsBackground) {
        NSMutableData *imageData = [NSMutableData data];
        uint8_t buffer[backgroundImageLength];
        NSInteger len;
        len = [inputStream read:buffer maxLength:sizeof(buffer)];
        if (len > 0) {
            [imageData appendBytes:(const void *)buffer length:len];
        }
        drawing.backgroundImage = [UIImage imageWithData:imageData];
    }
    
    return drawing;
}

+ (NSData *)encodeDrawingToData:(Drawing *)drawing
{
    NSOutputStream *outputStream = [[NSOutputStream alloc] initToMemory];
    [outputStream open];
    
    [outputStream writeInt32:MAGIC_NUMBER bigEndian:true];
    
    [outputStream writeInt16:ENCODING_VERSION bigEndian:true];
    
    [outputStream writeInt16:HEADER_LENGTH bigEndian:true];
    
    [outputStream writeInt16:LINE_HEADER_LENGTH bigEndian:true];
    
    [outputStream writeInt16:drawing.width bigEndian:true];
    
    [outputStream writeInt16:drawing.height bigEndian:true];
    
    NSData *imageData = nil;
    uint32_t imageLength = 0;
    if ([drawing.backgroundImage isKindOfClass:[UIImage class]]) {
        [outputStream writeInt16:1 bigEndian:true];
        imageData = UIImagePNGRepresentation(drawing.backgroundImage);
        imageLength = (uint32_t)imageData.length;
        [outputStream writeInt32:imageLength bigEndian:true];
    } else {
        [outputStream writeInt16:0 bigEndian:true];
        [outputStream writeInt32:0 bigEndian:true];
    }
    
    for (Line *line in drawing.lines) {
        [outputStream writeByte:0xF];
        [outputStream writeInt32:(uint32_t)[line getPointCount] bigEndian:true];
        [outputStream writeInt16:(uint16_t)line.brushType bigEndian:true];
        [outputStream writeInt32:(uint32_t)line.lineWidth bigEndian:true];
        
        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
        [line.color getRed:&red green:&green blue:&blue alpha:&alpha];
        int redInt =  (int) roundf(red * 255);
        int greenInt = (int) roundf(green * 255);
        int blueInt = (int) roundf(blue * 255);
        int alphaInt = (int) roundf(alpha * 255);
        [outputStream writeInt8:alphaInt];
        [outputStream writeInt8:redInt];
        [outputStream writeInt8:greenInt];
        [outputStream writeInt8:blueInt];
        
        for (NSValue *value in [line getPointsArrayOfNSValues]) {
            CGPoint point = [value CGPointValue];
            [outputStream writeFloat:point.x bigEndian:true];
            [outputStream writeFloat:point.y bigEndian:true];
        }
    }
    
    [outputStream writeByte:0x0];
    
    if ([imageData isKindOfClass:[NSData class]]) {
        [outputStream write:[imageData bytes] maxLength:imageLength];
    }
    
    NSData *data = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    [outputStream close];
    
    return data;
}

@end

