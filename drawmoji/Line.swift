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
        var updateRect = updateRectForLinePoint(point)
        
        if let last = points.last {
            let lastRect = updateRectForLinePoint(last)
            updateRect.unionInPlace(lastRect)
        }
        
        if points.count > 1 {
            let lastLastPoint = points[points.count - 2]
            let lastLastRect = updateRectForLinePoint(lastLastPoint)
            updateRect.unionInPlace(lastLastRect)
        }
        
        points.append(point)
        
        return updateRect
    }
    
    func cancel() -> CGRect {
        // Process each point in the line and accumulate the `CGRect` containing all the points.
        let updateRect = points.reduce(CGRect.null) { accumulated, point in
            return accumulated.union(updateRectForLinePoint(point))
        }
        return updateRect
    }
    
    // MARK: Drawing
    
    func drawInContext(context: CGContext) {
        var maybePriorPoint: CGPoint?
        var maybePriorPriorPoint: CGPoint?
        
        for point in points {
            let priorPoint = maybePriorPoint ?? point
            let priorPriorPoint = maybePriorPriorPoint ?? priorPoint
            
            let theColor = color.CGColor
            
            if(CGColorGetAlpha(theColor) == 0) {
                CGContextSetBlendMode(context, .Clear);
            } else {
                CGContextSetBlendMode(context, .Normal);
            }
            
            CGContextSetStrokeColorWithColor(context, theColor)
            CGContextSetLineWidth(context, lineWidth)
            CGContextBeginPath(context)
            let mid1 = midPointOfPoints(priorPoint,point2: priorPriorPoint);
            let mid2 = midPointOfPoints(point,point2: priorPoint);
            CGContextMoveToPoint(context, mid1.x, mid1.y)
            CGContextAddQuadCurveToPoint(context, priorPoint.x, priorPoint.y, mid2.x, mid2.y)
            CGContextStrokePath(context)
            
            maybePriorPriorPoint = maybePriorPoint
            maybePriorPoint = point
            
            CGContextSetBlendMode(context, .Normal);
        }
    }
    
    // MARK: Convenience
    
    func updateRectForLinePoint(point:CGPoint) -> CGRect {
        var rect = CGRect(origin:point, size: CGSize.zero)
        
        // The negative magnitude ensures an outset rectangle.
        let magnitude = -3 * lineWidth - 2
        rect.insetInPlace(dx: magnitude, dy: magnitude)
        
        return rect
    }
    
    func midPointOfPoints(point1:CGPoint,point2:CGPoint) -> CGPoint {
        return CGPointMake((point1.x + point2.x) * 0.5, (point1.y + point2.y) * 0.5)
    }
}
