/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The `CanvasView` tracks `UITouch`es and represents them as a series of `Line`s.
*/

import UIKit

class CanvasView: UIControl
{
    // MARK: Properties
    
    var lines = [Line]()
    var color = UIColor.blackColor()
    var size:CGFloat = 5.0
    var frozenImage:CGImage?
    
    ///
    private var activeLine:Line?
    ///
    private var unDidLines = [Line]()
    ///
    private var frozenImages = [CGImageRef]()
    private var unFrozenImages = [CGImageRef]()
    
    /// A `CGContext` for drawing the last representation of lines no longer receiving updates into.
    private lazy var frozenContext: CGContext = {
        let scale = self.window!.screen.scale
        var size = self.bounds.size
        
        size.width *= scale
        size.height *= scale
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)

        CGContextSetLineCap(context, .Round)
        let transform = CGAffineTransformMakeScale(scale, scale)
        CGContextConcatCTM(context, transform)
        
        return context!
    }()
    
    // MARK: Override
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            drawPoint(touch.locationInView(self))
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            drawPoint(touch.locationInView(self))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
             drawPoint(touch.locationInView(self))
        }
        endTouches(false)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        for touch in touches! {
            drawPoint(touch.locationInView(self))
        }
        endTouches(true)
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()!
        
        CGContextSetLineCap(context, .Round)
        
        if let image = frozenImage {
            CGContextDrawImage(context, bounds, image)
        }
        
        if let line = activeLine {
            line.drawInContext(context)
        }
    }
    
    // MARK: Actions
    
    func clear()
    {
        activeLine = nil
        lines.removeAll()
        unDidLines.removeAll()
        frozenImages.removeAll()
        unFrozenImages.removeAll()
        CGContextClearRect(frozenContext, bounds)
        frozenImage = CGBitmapContextCreateImage(frozenContext)
        setNeedsDisplay()
    }
    
    func back()
    {
        activeLine = nil
        if lines.count > 0 {
            unDidLines.append(lines.last!)
            lines.removeLast()
        }
        if frozenImages.count > 0 {
            unFrozenImages.append(frozenImages.last!)
            frozenImages.removeLast()
        }
        CGContextClearRect(frozenContext, bounds)
        if frozenImages.count > 0 {
            frozenImage = frozenImages.last
            CGContextDrawImage(frozenContext, bounds, frozenImage)
        } else {
            frozenImage = CGBitmapContextCreateImage(frozenContext)
        }
        setNeedsDisplay()
    }
    
    func forward()
    {
        activeLine = nil
        if unDidLines.count > 0 {
            lines.append(unDidLines.last!)
            unDidLines.removeLast()
        }
        if unFrozenImages.count > 0 {
            frozenImages.append(unFrozenImages.last!)
            unFrozenImages.removeLast()
            frozenImage = frozenImages.last
            CGContextClearRect(frozenContext, bounds)
            CGContextDrawImage(frozenContext, bounds, frozenImage)
        }
        setNeedsDisplay()
    }
    
    // MARK: Convenience
    
    func drawPoint(point:CGPoint) {
        if unDidLines.count > 0 {
            unDidLines.removeAll()
        }
        if unFrozenImages.count > 0 {
            unFrozenImages.removeAll()
        }
        
        let line = activeLine ?? addActiveLine()
        let rect = line.addPointAtLocation(point)
        setNeedsDisplayInRect(rect)
    }
    
    func addActiveLine() -> Line {
        let newLine = Line()
        newLine.color = color
        newLine.size = size
        
        activeLine = newLine
        
        lines.append(newLine)
        
        print("\(lines.count)")
        
        return newLine
    }
    
    func endTouches(cancel: Bool) {
        if let line = activeLine {
            var updateRect = CGRect.null
            
            if cancel { updateRect.unionInPlace(line.cancel()) }
            
            finishLine(line)
            
            activeLine = nil
            
            setNeedsDisplay()
        }
    }
    
    func finishLine(line: Line) {
        line.drawInContext(frozenContext)
        
        let image = CGBitmapContextCreateImage(frozenContext)
        if let image = image {
            let imageAsData = UIImagePNGRepresentation(UIImage(CGImage: image))
            if let imageAsData = imageAsData {
                let downsampledImaged = UIImage(data:imageAsData);
                frozenImage = downsampledImaged?.CGImage
                frozenImages.append((downsampledImaged?.CGImage)!)
            } else {
                lines.removeLast()
            }
        }
    }
}
