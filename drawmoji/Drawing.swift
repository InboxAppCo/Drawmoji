//
//  Drawing.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/5/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import Foundation
import UIKit

class Drawing:NSObject {
    
    var lines:[Line] = [Line]()
    var height:Int = 0
    var width:Int = 0
    var backgroundImage:UIImage?
    
    class func parseLegacyDrawingFromJson(paths:NSArray,height:NSInteger,width:NSInteger,lineWidth:CGFloat,image:UIImage?) -> Drawing? {
        if let theDrawing = DrawingJsonProcessor.decodeDrawingFromFile(paths, height: height, width: width, lineWidth: lineWidth, image: image) {
            return theDrawing
        } else {
            return nil
        }
    }
    
    class func parseBinaryDrawingFromData(data:NSData) -> Drawing? {
        if let theDrawing = DrawingBinaryProcessor.decodeDrawingFromData(data) {
            return theDrawing
        } else {
            return nil
        }
    }
    
//    class func writeDrawingToFile(drawing:Drawing,file:NSData,legacy:Bool) -> Bool {
//        if legacy {
//            
//        } else {
//            
//        }
//    }
    
    func addLine(line:Line) {
        lines.append(line)
    }
    
    func pointCount() -> Int {
        var pointCount:Int = 0
        for line in lines {
            pointCount = pointCount + line.points.count
        }
        return pointCount
    }
    
    func lineForPoint(pointCount:Int) -> (line:Line?, pointCountInLine:Int) {
        var pointsCounted = 0
        var theLine:Line?
        var pointCountInLine:Int = 0
        for line in lines {
            pointsCounted = pointsCounted + line.points.count
            if pointsCounted > pointCount {
                theLine = line
                let prelim = pointsCounted - line.points.count
                pointCountInLine = pointCount - prelim
                break
            }
        }
        return (theLine, pointCountInLine)
    }
    
    class func aspectFitDrawingInSize(drawing:Drawing, size:CGSize) -> Drawing {
        let originalWidthFloat = CGFloat(drawing.width)
        let originalHeightFloat = CGFloat(drawing.height)
        
        let scale = Drawing.scaleToAspectFitSizeInSize(CGSizeMake(originalWidthFloat,originalHeightFloat), target:size)
        
        let newDrawing = Drawing()
        newDrawing.backgroundImage = drawing.backgroundImage
        newDrawing.width = Int(originalWidthFloat*scale)
        newDrawing.height = Int(originalHeightFloat*scale)
        
        for line in drawing.lines {
            let newLine = Line()
            newLine.color = line.color
            newLine.lineWidth = line.lineWidth * scale
            for point in line.points {
                let newPoint = CGPoint(x: point.x * scale, y: point.y * scale)
                newLine.addPointAtLocation(newPoint)
            }
            newDrawing.addLine(newLine)
        }
        
        return newDrawing;
    }
    
    private class func scaleToAspectFitSizeInSize(original:CGSize, target:CGSize) -> CGFloat {
        // first try to match width
        let s = target.width / original.width;
        // if we scale the height to make the widths equal, does it still fit?
        if (original.height * s <= target.height) {
            return s;
        }
        // no, match height instead
        return target.height / original.height;
    }
}
