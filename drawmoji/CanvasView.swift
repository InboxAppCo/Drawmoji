/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The `CanvasView` tracks `UITouch`es and represents them as a series of `Line`s.
*/

import UIKit

protocol CanvasViewDelegate:class
{
    func didUpdateUndoRedoCounts(undoCount:Int, redoCount:Int)
    func willBeginForceDrawingAllLines()
    func didFinishForceDrawingAllLines()
    func willBeginDrawingLine()
    func didFinishDrawingLine()
}

class CanvasView: UIControl
{
    weak var delegate:CanvasViewDelegate?
    
    var lines:[Line]
    private var redoLines:[Line] = [Line]()
    
    var currentColor = UIColor.blackColor()
    var currentLineWidth:CGFloat = 5.0
    
    private var currentFrozenImage:CGImage?
    
    private var undoCount:Int = 0
    private var redoCount:Int = 0
    
    private var activeLine:Line?
    
    private var frozenUndoImages = [NSData]()
    private var frozenRedoImages = [NSData]()
    
    /// A `CGContext` for drawing the last representation of lines no longer receiving updates into.
    private lazy var frozenContext: CGContext = {
        let scale = UIApplication.sharedApplication().delegate!.window!!.screen.scale
        var size = self.bounds.size
        
        size.width *= scale
        size.height *= scale
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        CGContextScaleCTM(context, scale, scale)
        
        CGContextSetLineCap(context, .Round)
        
        return context!
    }()
    
    // MARK: Override
    
    init(frame:CGRect, lines:[Line])
    {
        self.lines = lines
        super.init(frame: frame)
    }
    
    override init(frame: CGRect)
    {
        lines = [Line]()
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        delegate?.willBeginDrawingLine()
        
        redoLines.removeAll()
        redoCount = 0
        frozenRedoImages.removeAll()
        
        for touch in touches {
            drawPoint(touch.locationInView(self))
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches {
            drawPoint(touch.locationInView(self))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        endTouches(false)
        
        delegate?.didFinishDrawingLine()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        endTouches(true)
        
        delegate?.didFinishDrawingLine()
    }
    
    // MARK: Drawing
    
    override func drawRect(rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()!
        
        CGContextSetLineCap(context, .Round)
        
        if let image = currentFrozenImage {
            CGContextDrawImage(context, bounds, image)
        }
        
        if let line = activeLine {
            line.drawLineInContext(context)
        }
    }
    
    // MARK: Actions
    
    func clear()
    {
        activeLine = nil
        lines.removeAll()
        redoLines.removeAll()
        frozenUndoImages.removeAll()
        frozenRedoImages.removeAll()
        undoCount = 0
        redoCount = 0
        CGContextClearRect(frozenContext, bounds)
        currentFrozenImage = nil
        setNeedsDisplay()
        updateUndoRedoCounts()
    }
    
    func undo()
    {
        if undoCount == 0 {
            return
        }
        
        activeLine = nil
        if frozenUndoImages.count > 0 && lines.count > 0, let lastImage = frozenUndoImages.last, let lastLine = lines.last {
            frozenRedoImages.append(lastImage)
            frozenUndoImages.removeLast()
            redoLines.append(lastLine)
            lines.removeLast()
            
            CGContextClearRect(frozenContext, bounds)
            if frozenUndoImages.count > 0 {
                currentFrozenImage = UIImage(data:frozenUndoImages.last!)?.CGImage
                CGContextDrawImage(frozenContext, bounds, currentFrozenImage)
            } else if lines.count == 0 {
                currentFrozenImage = nil
            }
            setNeedsDisplay()
            undoCount--
            redoCount++
            updateUndoRedoCounts()
        }
    }
    
    func undoAll()
    {
        if undoCount == 0 {
            return
        }
        
        activeLine = nil
        if frozenUndoImages.count > 0 && lines.count > 0 {
            frozenRedoImages.appendContentsOf(frozenUndoImages.reverse())
            frozenUndoImages.removeAll()
            
            redoLines.appendContentsOf(lines.reverse())
            lines.removeAll()
            
            currentFrozenImage = nil
            
            setNeedsDisplay()
            undoCount = 0
            redoCount = redoLines.count
            updateUndoRedoCounts()
        }
    }
    
    func redo()
    {
        if redoCount == 0 {
            return
        }
        
        activeLine = nil
        if frozenRedoImages.count > 0 && redoLines.count > 0, let lastImageData = frozenRedoImages.last, let lastLine = redoLines.last {
            frozenUndoImages.append(lastImageData)
            frozenRedoImages.removeLast()
            lines.append(lastLine)
            redoLines.removeLast()
            currentFrozenImage = UIImage(data:lastImageData)?.CGImage
            CGContextDrawImage(frozenContext, bounds, currentFrozenImage)
            setNeedsDisplay()
            undoCount++
            redoCount--
            updateUndoRedoCounts()
        }
    }
    
    func redoAll()
    {
        if redoCount == 0 {
            return
        }
        
        activeLine = nil
        if frozenRedoImages.count > 0 && redoLines.count > 0 {
            frozenUndoImages.appendContentsOf(frozenRedoImages.reverse())
            frozenRedoImages.removeAll()
            
            lines.appendContentsOf(redoLines.reverse())
            redoLines.removeAll()
            
            currentFrozenImage = UIImage(data:frozenUndoImages.last!)?.CGImage
            
            setNeedsDisplay()
            undoCount = lines.count
            redoCount = 0
            updateUndoRedoCounts()
        }
    }
    
    // MARK: Convenience
    
    func drawPoint(point:CGPoint)
    {
        let line = activeLine ?? addActiveLine()
        line.addPointAtLocation(point)
        setNeedsDisplay()
    }
    
    func addActiveLine() -> Line
    {
        let newLine = Line()
        newLine.color = currentColor
        newLine.lineWidth = currentLineWidth
        
        activeLine = newLine
        
        lines.append(newLine)
        
        return newLine
    }
    
    func endTouches(cancel: Bool)
    {
        if let line = activeLine {
            var updateRect = CGRect.null
            
            if cancel { updateRect.unionInPlace(line.cancel()) }
            
            finishLine(line)
            
            activeLine = nil
            
            setNeedsDisplay()
            
            updateUndoRedoCounts()
        }
    }
    
    func finishLine(line: Line)
    {
        autoreleasepool {
            line.drawLineInContext(frozenContext)
            
            let image = CGBitmapContextCreateImage(frozenContext)
            if let theImage = image {
                let imageAsData = UIImagePNGRepresentation(UIImage(CGImage: theImage))
                if let imageAsData = imageAsData {
                    let downsampledImaged = UIImage(data:imageAsData);
                    currentFrozenImage = downsampledImaged?.CGImage
                    frozenUndoImages.append(imageAsData)
                } else {
                    lines.removeLast()
                }
            }
            
            undoCount++
        }        
    }
    
    func updateUndoRedoCounts()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.didUpdateUndoRedoCounts(self.undoCount, redoCount: self.redoCount)
        }
    }
    
    func forceDrawAllLines()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.willBeginForceDrawingAllLines()
        }
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            for line in self.lines {
                self.finishLine(line)
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.setNeedsDisplay()
                self.delegate?.didFinishForceDrawingAllLines()
                self.delegate?.didUpdateUndoRedoCounts(self.undoCount, redoCount: self.redoCount)
            }
        }
    }
    
    deinit {
    
    }
}
