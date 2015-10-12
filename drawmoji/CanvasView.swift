/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The `CanvasView` tracks `UITouch`es and represents them as a series of `Line`s.
*/

import UIKit

protocol CanvasViewDelegate {
    func updatedUndoRedoCounts(undoCount:Int)
    func willForceDrawAllLines(background:Bool)
    func didForceDrawAllLines(background:Bool)
}

class CanvasView: UIControl
{
    // MARK: Properties
    
    var delegate:CanvasViewDelegate?
    var lines:[Line]
    var currentColor = UIColor.blackColor()
    var currentLineWidth:CGFloat = 5.0
    var frozenImage:CGImage?
    var backCount:Int = 0
    
    ///
    private var activeLine:Line?
    ///
    private var frozenImages = [CGImageRef]()
    
    /// A `CGContext` for drawing the last representation of lines no longer receiving updates into.
    private lazy var frozenContext: CGContext = {
        let scale = UIApplication.sharedApplication().delegate!.window!!.screen.scale
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
    
    init(frame:CGRect, lines:[Line]) {
        self.lines = lines
        super.init(frame: frame)
    }
    
    override init(frame: CGRect) {
        lines = [Line]()
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        endTouches(false)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
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
        frozenImages.removeAll()
        CGContextClearRect(frozenContext, bounds)
        frozenImage = CGBitmapContextCreateImage(frozenContext)
        setNeedsDisplay()
    }
    
    func back()
    {
        if backCount == 0 {
            return
        }
        
        activeLine = nil
        if frozenImages.count > 0 {
            frozenImages.removeLast()
            
            if lines.count > 0 {
                lines.removeLast()
            }
        }
        CGContextClearRect(frozenContext, bounds)
        if frozenImages.count > 0 {
            frozenImage = frozenImages.last
            CGContextDrawImage(frozenContext, bounds, frozenImage)
        } else if lines.count == 0 {
            frozenImage = nil
        }
        setNeedsDisplay()
        backCount--
        updateUndoRedoCounts()
    }
    
    // MARK: Convenience
    
    func drawPoint(point:CGPoint) {
        let line = activeLine ?? addActiveLine()
        let rect = line.addPointAtLocation(point)
        setNeedsDisplayInRect(rect)
    }
    
    func addActiveLine() -> Line {
        let newLine = Line()
        newLine.color = currentColor
        newLine.lineWidth = currentLineWidth
        
        activeLine = newLine
        
        lines.append(newLine)
        
        return newLine
    }
    
    func endTouches(cancel: Bool) {
        if let line = activeLine {
            var updateRect = CGRect.null
            
            if cancel { updateRect.unionInPlace(line.cancel()) }
            
            finishLine(line)
            
            activeLine = nil
            
            setNeedsDisplay()
            
            updateUndoRedoCounts()
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
                if frozenImages.count > 21 {
                    frozenImages.removeFirst()
                }
            } else {
                lines.removeLast()
            }
        }
        
        if backCount < 20 {
            backCount++
        }
    }
    
    func updateUndoRedoCounts() {
        if let delegate = delegate {
            delegate.updatedUndoRedoCounts(backCount)
        }
    }
    
    func forceDrawAllLines(background:Bool) {
        if let delegate = delegate {
            delegate.willForceDrawAllLines(background)
        }
        if background {
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) { // 1
                for line in self.lines {
                    self.finishLine(line)
                }
                dispatch_async(dispatch_get_main_queue()) { // 2
                    self.setNeedsDisplay()
                    if let delegate = self.delegate {
                        delegate.didForceDrawAllLines(background)
                    }
                }
            }
        } else {
            for line in self.lines {
                finishLine(line)
            }
            setNeedsDisplay()
            if let delegate = delegate {
                delegate.didForceDrawAllLines(background)
            }
        }
    }
}
