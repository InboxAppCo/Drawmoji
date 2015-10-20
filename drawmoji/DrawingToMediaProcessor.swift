//
//  DrawingToMediaProcessor.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/20/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import UIKit

class DrawingToMediaProcessor {
    class func imageFromDrawing(drawing:Drawing) -> UIImage?
    {
        let scale = UIApplication.sharedApplication().delegate!.window!!.screen.scale
        var size:CGSize = CGSize(width: drawing.width, height: drawing.height)
        
        size.width *= scale
        size.height *= scale
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        CGContextScaleCTM(context, scale, scale)
        
        if let backgroundImage = drawing.backgroundImage {
            CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: drawing.width, height: drawing.height)), backgroundImage.CGImage)
        } else {
            CGContextSetRGBFillColor(context, 1, 1, 1, 1);
            CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
        }
        
        CGContextTranslateCTM(context, 0, CGFloat(drawing.height))
        CGContextScaleCTM(context, 1, -1)
        
        for line in drawing.lines {
            line.drawLineInContext(context!)
        }
        
        let image = CGBitmapContextCreateImage(context)
        if let theImage = image {
            let imageAsData = UIImagePNGRepresentation(UIImage(CGImage: theImage))
            if let imageAsData = imageAsData {
                return UIImage(data:imageAsData)
            }
        }
        
        return nil
    }
    
    class func videoFromDrawing(drawing:Drawing, size:CGSize)
    {
        
    }
}