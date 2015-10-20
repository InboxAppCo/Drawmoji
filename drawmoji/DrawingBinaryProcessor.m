//
//  DrawingBinaryProcessor.m
//  binaryProcessor
//
//  Created by Hani Shabsigh on 10/13/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

#import "DrawingBinaryProcessor.h"
#import "NSInputStream+Inbox.h"
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
    int lineWidth = [inputStream readInt16:true];
    
    BOOL containsBackground = ([inputStream readInt16:true] == 1)?true:false;
    
    if (headerLength > HEADER_LENGTH) {
        uintmax_t value = 0;
        [inputStream read:(uint8_t *)&value maxLength:headerLength-HEADER_LENGTH];
    }
    
    Byte endFlag = [inputStream readByte];
    while (endFlag == ANOTHER_LINE) {
        int pointCount = [inputStream readInt32:true];
        
        Line *line = [[Line alloc] init];
        int aInt = [inputStream readInt8];
        int rInt = [inputStream readInt8];
        int gInt = [inputStream readInt8];
        int bInt = [inputStream readInt8];
        float a = aInt/255.0f;
        float r = rInt/255.0f;
        float g = gInt/255.0f;
        float b = bInt/255.0f;
        line.color = [UIColor colorWithRed:r green:g blue:b alpha:a];
        
        line.lineWidth = (lineWidth>0)?lineWidth:5;
        
        if (lineHeaderLength > LINE_HEADER_LENGTH) {
            uintmax_t value = 0;
            [inputStream read:(uint8_t *)&value maxLength:lineHeaderLength-LINE_HEADER_LENGTH];
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
        uint8_t buffer[5000];
        NSInteger len;
        while ([inputStream hasBytesAvailable]) {
            len = [inputStream read:buffer maxLength:sizeof(buffer)];
            if (len > 0) {
                [imageData appendBytes:(const void *)buffer length:len];
            }
        }
        drawing.backgroundImage = [UIImage imageWithData:imageData];
    }
    
    return drawing;
}

+ (NSData *)writeDataFromDrawing:(Drawing *)drawing {
    NSMutableData *data = nil;
    
    return data;
}

@end

