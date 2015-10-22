//
//  DrawingCanvasView.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/6/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import UIKit

@objc protocol DrawingCanvasViewDelegate:class
{
  optional func drawingCanvasView(drawingCanvasView:DrawingCanvasView, willBeginDrawingLine:Line)
  optional func drawingCanvasView(drawingCanvasView:DrawingCanvasView, didFinishDrawingLine:Line)
  
  optional func drawingCanvasView(drawingCanvasView:DrawingCanvasView, didUpdateUndoCount:Int, redoCount:Int)
  optional func drawingCanvasView(drawingCanvasView:DrawingCanvasView, didUndoLine:Line)
  optional func drawingCanvasView(drawingCanvasView:DrawingCanvasView, didRedoLine:Line)
  
  optional func drawingCanvasViewWillBeginForceDrawingAllLines(drawingCanvasView:DrawingCanvasView)
  optional func drawingCanvasViewDidFinishForceDrawingAllLines(drawingCanvasView:DrawingCanvasView)
}

class DrawingCanvasView:UIView, UIScrollViewDelegate
{
    private var scrollView:UIScrollView
    private var containerView:UIView
    private var backgroundImageView:UIImageView
    private var canvasView:CanvasView
    private var drawing:Drawing
    private var hiddenDelegate:DrawingCanvasViewDelegateHandler?
    weak var delegate:DrawingCanvasViewDelegate?
    
    init(drawing:Drawing, frame:CGRect)
    {
        self.drawing = drawing
        
        containerView = UIView(frame: CGRect(origin: CGPointZero, size:frame.size))
        
        scrollView = UIScrollView(frame: CGRect(origin: CGPointZero, size:frame.size))
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollView.minimumZoomScale = 1.00
        scrollView.maximumZoomScale = 4.00
        scrollView.scrollsToTop = false
        scrollView.addSubview(containerView)
        
        backgroundImageView = UIImageView(frame: CGRect(origin: CGPointZero, size: frame.size))
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFit
        backgroundImageView.image = drawing.backgroundImage
        containerView.addSubview(backgroundImageView)
        
        canvasView = CanvasView(frame: CGRect(origin:CGPointZero, size:frame.size), lines:drawing.lines)
        canvasView.backgroundColor = UIColor.clearColor()
        canvasView.layer.borderColor = UIColor.lightGrayColor().CGColor
        canvasView.layer.borderWidth = 0.5
        containerView.addSubview(canvasView)
        
        super.init(frame:frame)
        
        scrollView.delegate = self
        addSubview(scrollView)
        hiddenDelegate = DrawingCanvasViewDelegateHandler(outer: self)
        canvasView.delegate = hiddenDelegate
    }
    
    override init(frame: CGRect)
    {
        drawing = Drawing()
        drawing.width = Int(frame.width)
        drawing.height = Int(frame.height)
        
        containerView = UIView(frame: CGRect(origin: CGPointZero, size: frame.size))
        
        scrollView = UIScrollView(frame: CGRect(origin: CGPointZero, size: frame.size))
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollView.minimumZoomScale = 1.00
        scrollView.maximumZoomScale = 4.00
        scrollView.scrollsToTop = false
        scrollView.addSubview(containerView)
        
        backgroundImageView = UIImageView(frame: CGRect(origin: CGPointZero, size: frame.size))
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFit
        containerView.addSubview(backgroundImageView)
        
        canvasView = CanvasView(frame: CGRect(origin: CGPointZero, size: frame.size))
        canvasView.backgroundColor = UIColor.clearColor()
        canvasView.layer.borderColor = UIColor.lightGrayColor().CGColor
        canvasView.layer.borderWidth = 0.5
        containerView.addSubview(canvasView)
        
        super.init(frame: frame)
        
        scrollView.delegate = self
        addSubview(scrollView)
        hiddenDelegate = DrawingCanvasViewDelegateHandler(outer: self)
        canvasView.delegate = hiddenDelegate
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return containerView
    }
    
    // MARK: Function
    
    func setBackgroundImage(image:UIImage?)
    {
        drawing.backgroundImage = image
        backgroundImageView.image = image
    }
    
    func setCurrentColor(color:UIColor)
    {
        canvasView.currentColor = color
    }
    
    func setCurrentLineWidth(lineWidth:CGFloat)
    {
        canvasView.currentLineWidth = lineWidth
    }
    
    func clear()
    {
        canvasView.clear()
    }
    
    func undo()
    {
        canvasView.undo()
    }
    
    func undoAll()
    {
        canvasView.undoAll()
    }
    
    func redo()
    {
        canvasView.redo()
    }
    
    func redoAll()
    {
        canvasView.redoAll()
    }
    
    func forceDrawAllLines ()
    {
        canvasView.forceDrawAllLines()
    }
    
    func getDrawing() -> Drawing
    {
        drawing.lines = canvasView.lines
        drawing.backgroundImage = backgroundImageView.image
        return drawing;
    }
    
    deinit {
        
    }
}

private class DrawingCanvasViewDelegateHandler:NSObject, CanvasViewDelegate {
    
    private weak var outer:DrawingCanvasView?
    
    init(outer:DrawingCanvasView)
    {
        self.outer = outer
        super.init()
    }
    
    // MARK: CanvasViewDelegate
    
    func didUpdateUndoRedoCounts(undoCount: Int, redoCount: Int)
    {
        outer?.delegate?.drawingCanvasView?(outer!, didUpdateUndoCount: undoCount, redoCount: redoCount)
    }
    
    func willBeginForceDrawingAllLines()
    {
        outer?.delegate?.drawingCanvasViewWillBeginForceDrawingAllLines?(outer!)
    }
    
    func didFinishForceDrawingAllLines()
    {
        outer?.delegate?.drawingCanvasViewDidFinishForceDrawingAllLines?(outer!)
    }
    
    func willBeginDrawingLine(line: Line)
    {
        outer?.delegate?.drawingCanvasView?(outer!, willBeginDrawingLine:line)
    }
    
    func didFinishDrawingLine(line: Line)
    {
        outer?.delegate?.drawingCanvasView?(outer!, didFinishDrawingLine:line)
    }
  
  func didUndoLine(line: Line)
  {
    outer?.delegate?.drawingCanvasView?(outer!, didUndoLine:line)
  }
  
  func didRedoLine(line: Line)
  {
    outer?.delegate?.drawingCanvasView?(outer!, didRedoLine:line)
  }
}
