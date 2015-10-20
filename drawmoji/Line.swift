/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Contains the `Line` and `LinePoint` types used to represent and draw lines derived from touches.
*/

import UIKit

class Line: NSObject {
    // MARK: Properties
    
    var points = [CGPoint]()
    var color:UIColor = UIColor.blackColor()
    var lineWidth:CGFloat = 5.0
    
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
        
        let theColor = color.CGColor
        if(CGColorGetAlpha(theColor) == 0) {
            CGContextSetBlendMode(context, .Clear);
        } else {
            CGContextSetBlendMode(context, .Normal);
        }
        
        CGContextSetLineWidth(context, lineWidth)
            
        CGContextSetStrokeColorWithColor(context, theColor)
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
        
        let theColor = color.CGColor
        if(CGColorGetAlpha(theColor) == 0) {
            CGContextSetBlendMode(context, .Clear);
        } else {
            CGContextSetBlendMode(context, .Normal);
        }
        
        CGContextSetLineWidth(context, lineWidth)
        
        for point in points {
            let priorPoint = maybePriorPoint ?? point
            let priorPriorPoint = maybePriorPriorPoint ?? priorPoint
            
            CGContextSetStrokeColorWithColor(context, theColor)
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
