//
//  Drawing.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/5/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import Foundation
import UIKit

class Drawing:NSObject, NSCoding
{
    // MARK: Properties
    
    var lines:[Line] = [Line]()
    var width:Int = 0
    var height:Int = 0
    var backgroundImage:UIImage?
    
    // MARK: Init
    
    override init()
    {
        
    }
    
    convenience init(lines:[Line], width:Int, height:Int, backgroundImage:UIImage?)
    {
        self.init()
        self.lines = lines
        self.width = width
        self.height = height
        self.backgroundImage = backgroundImage
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        self.init()
        lines = aDecoder.decodeObjectForKey("lines") as! [Line]
        width = aDecoder.decodeObjectForKey("width") as! Int
        height = aDecoder.decodeObjectForKey("height") as! Int
        backgroundImage = aDecoder.decodeObjectForKey("backgroundImage") as? UIImage
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(lines, forKey: "lines")
        aCoder.encodeObject(width, forKey: "width")
        aCoder.encodeObject(height, forKey: "height")
        aCoder.encodeObject(backgroundImage, forKey: "backgroundImage")
    }
    
    // MARK: Class Functionsxb
    
    class func parseDrawingFromData(data:NSData, image:UIImage?) -> Drawing?
    {
        var magic: UInt32 = 0
        data.getBytes(&magic, length:4)
        let flipped = CFSwapInt32HostToBig(magic)
        if flipped == 0xF0E1D2C3 {
            return parseBinaryDrawingFromData(data)
        } else {
            return parseLegacyDrawingFromJson(data, image: image)
        }
    }
    
    class func writeDataFromDrawing(drawing:Drawing, legacy:Bool) -> NSData?
    {
        if !legacy {
            return writeDrawingToBinaryFile(drawing)
        } else {
            return writeDrawingToJsonFile(drawing)
        }
    }
    
    private class func parseBinaryDrawingFromData(data:NSData) -> Drawing?
    {
        if let theDrawing = DrawingBinaryProcessor.decodeDrawingFromData(data) {
            return theDrawing
        } else {
            return nil
        }
    }
    
    private class func parseLegacyDrawingFromJson(data:NSData, image:UIImage?) -> Drawing?
    {
        if let theDrawing = DrawingJsonProcessor.decodeDrawingFromData(data, image:image) {
            return theDrawing
        } else {
            return nil
        }
    }
    
    private class func writeDrawingToBinaryFile(drawing:Drawing) -> NSData?
    {
        if let theData = DrawingBinaryProcessor.encodeDrawingToData(drawing) {
            return theData
        } else {
            return nil
        }
    }
    
    private class func writeDrawingToJsonFile(drawing:Drawing) -> NSData?
    {
        if let theDrawing = DrawingJsonProcessor.encodeDrawingToData(drawing) {
            return theDrawing
        } else {
            return nil
        }
    }
    
    func addLine(line:Line)
    {
        lines.append(line)
    }
    
    func pointCount() -> Int
    {
        var pointCount:Int = 0
        for line in lines {
            pointCount = pointCount + line.points.count
        }
        return pointCount
    }
    
    func lineForPoint(pointCount:Int) -> (line:Line?, pointCountInLine:Int)
    {
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
    
    class func aspectFitDrawingInSize(drawing:Drawing, size:CGSize) -> Drawing
    {
        let originalWidthFloat = CGFloat(drawing.width)
        let originalHeightFloat = CGFloat(drawing.height)
        
        let scale = Drawing.scaleToAspectFitSizeInSize(CGSizeMake(originalWidthFloat,originalHeightFloat), target:size)
        
        let newDrawing = Drawing()
        newDrawing.backgroundImage = drawing.backgroundImage
        newDrawing.width = Int(originalWidthFloat)
        newDrawing.height = Int(originalHeightFloat)
        
        let widthAdjustment = (originalWidthFloat - (originalWidthFloat * scale))/2
        let heightAdjustment = (originalHeightFloat - (originalHeightFloat * scale))/2
        
        for line in drawing.lines {
            let newLine = Line()
            newLine.color = line.color
            newLine.lineWidth = line.lineWidth * scale
            newLine.brushType = line.brushType
            for point in line.points {
                let newPoint = CGPoint(x: point.x * scale + widthAdjustment, y: point.y * scale + heightAdjustment)
                newLine.addPointAtLocation(newPoint)
            }
            newDrawing.addLine(newLine)
        }
        
        return newDrawing;
    }
    
    private class func scaleToAspectFitSizeInSize(original:CGSize, target:CGSize) -> CGFloat
    {
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
