//
//  DrawingBinaryProcessor.h
//  binaryProcessor
//
//  Created by Hani Shabsigh on 10/13/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Drawing;

@interface DrawingBinaryProcessor : NSObject

+ (Drawing *)decodeDrawingFromData:(NSData *)data;
+ (NSData *)writeDataFromDrawing:(Drawing *)drawing;

@end
