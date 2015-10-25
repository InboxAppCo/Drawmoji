/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Contains the `Line` and `LinePoint` types used to represent and draw lines derived from touches.
*/

import UIKit

@objc enum BrushType: Int {
    case Pencil = 0
    case Eraser = 1
}

class Line: NSObject
{
    // MARK: Properties
    
    var points = [CGPoint]()
    var brushType:BrushType = .Pencil // 0 = pencil, 1 = eraser
    var lineWidth:CGFloat = 5.0
    var color:UIColor = UIColor.blackColor()
    
    // MARK: Init
    
    override init()
    {
        
    }
    
    convenience init(points:[CGPoint], brushType:BrushType, lineWidth:CGFloat, color:UIColor)
    {
        self.init()
        self.points = points
        self.brushType = brushType
        self.lineWidth = lineWidth
        self.color = color
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        self.init()
        points = convertNSArrayOfNSValuesToArrayOfCGPoints(aDecoder.decodeObjectForKey("points") as! NSArray)
        brushType = aDecoder.decodeObjectForKey("brushType") as! BrushType
        lineWidth = aDecoder.decodeObjectForKey("lineWidth") as! CGFloat
        color = aDecoder.decodeObjectForKey("color") as! UIColor
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(convertArrayOfCGPointsToNSArrayOfNSValues(points), forKey: "points")
        aCoder.encodeObject(brushType.rawValue, forKey: "brushType")
        aCoder.encodeObject(lineWidth, forKey: "lineWidth")
        aCoder.encodeObject(color, forKey: "color")
    }
    
    // MARK: Interface
    
    func addPointAtLocation(point:CGPoint) -> CGRect {
        points.append(point)
        return updateRectForLinePoint(point)
    }
    
    func cancel() -> CGRect {
        // Process each point in the line and accumulate the `CGRect` containing all the points.
        let updateRect = points.reduce(CGRect.null) { accumulated, point in
            return accumulated.union(updateRectForPoint(point))
        }
        return updateRect
    }
    
    func getPointCount() -> Int {
        return points.count
    }
    
    func getPointsArrayOfNSValues() -> NSArray {
        return convertArrayOfCGPointsToNSArrayOfNSValues(points)
    }
    
    private func convertArrayOfCGPointsToNSArrayOfNSValues(array:[CGPoint]) -> NSArray
    {
        let nsarray = NSMutableArray()
        for point in array {
            nsarray.addObject(NSValue(CGPoint:point))
        }
        return nsarray;
    }
    
    private func convertNSArrayOfNSValuesToArrayOfCGPoints(nsarray:NSArray) -> [CGPoint]
    {
        var array:[CGPoint] = [CGPoint]()
        for value in nsarray {
            array.append(value.CGPointValue)
        }
        return array
    }
    
    // MARK: Drawing
    
    func drawPointInContext(pointCount:Int, context:CGContext) {
        CGContextSaveGState(context)
        
        CGContextSetLineCap(context, .Round)
        
        let point = points[pointCount]
        var priorPoint = point
        var priorPriorPoint = point
        
        if pointCount > 0 {
            priorPoint = points[pointCount-1]
            priorPriorPoint = priorPoint
        }
        if pointCount > 1 {
            priorPoint = points[pointCount-1]
            priorPriorPoint = points[pointCount-2]
        }
        
        CGContextSetLineWidth(context, lineWidth)
        if(brushType == .Eraser) {
            CGContextSetBlendMode(context, .Clear);
        } else {
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            CGContextSetBlendMode(context, .Normal);
        }
        
        CGContextBeginPath(context)
        let mid1 = midPointOfPoints(priorPoint,point2: priorPriorPoint);
        let mid2 = midPointOfPoints(point,point2: priorPoint);
        CGContextMoveToPoint(context, mid1.x, mid1.y)
        CGContextAddQuadCurveToPoint(context, priorPoint.x, priorPoint.y, mid2.x, mid2.y)
        CGContextStrokePath(context)
        
        CGContextRestoreGState(context)
    }
    
    func drawLineInContext(context: CGContext) {
        CGContextSaveGState(context)
        
        CGContextSetLineCap(context, .Round)
        
        var maybePriorPoint: CGPoint?
        var maybePriorPriorPoint: CGPoint?
        
        CGContextSetLineWidth(context, lineWidth)
        if(brushType == .Eraser) {
            CGContextSetBlendMode(context, .Clear);
        } else {
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            CGContextSetBlendMode(context, .Normal);
        }
        
        for point in points {
            let priorPoint = maybePriorPoint ?? point
            let priorPriorPoint = maybePriorPriorPoint ?? priorPoint
            
            CGContextBeginPath(context)
            let mid1 = midPointOfPoints(priorPoint,point2: priorPriorPoint);
            let mid2 = midPointOfPoints(point,point2: priorPoint);
            CGContextMoveToPoint(context, mid1.x, mid1.y)
            CGContextAddQuadCurveToPoint(context, priorPoint.x, priorPoint.y, mid2.x, mid2.y)
            CGContextStrokePath(context)
            
            maybePriorPriorPoint = maybePriorPoint
            maybePriorPoint = point
        }
        
        CGContextRestoreGState(context)
    }
    
    // MARK: Convenience
    
    func updateRectForPoint(point:CGPoint) -> CGRect {
        var rect = CGRect(origin:point, size: CGSize.zero)
        
        // The negative magnitude ensures an outset rectangle.
        let magnitude = -3 * lineWidth - 2
        rect.insetInPlace(dx: magnitude, dy: magnitude)
        
        return rect
    }
    
    func updateRectForLinePoint(point:CGPoint) -> CGRect {
        var updateRect = updateRectForPoint(point)
        
        if points.count > 1 {
            let lastPoint = points[points.count-1]
            let lastRect = updateRectForPoint(lastPoint)
            updateRect.unionInPlace(lastRect)
        }
        
        if points.count > 2 {
            let lastLastPoint = points[points.count - 2]
            let lastLastRect = updateRectForPoint(lastLastPoint)
            updateRect.unionInPlace(lastLastRect)
        }
        
        return updateRect
    }
    
    func midPointOfPoints(point1:CGPoint,point2:CGPoint) -> CGPoint {
        return CGPointMake((point1.x + point2.x) * 0.5, (point1.y + point2.y) * 0.5)
    }
}
