//
//  DrawingCanvasView.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/6/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import UIKit

protocol DrawingCanvasViewDelegate {
    func updatedUndoRedoCounts(undoCount:Int)
}

class DrawingCanvasView:UIView, UIScrollViewDelegate, CanvasViewDelegate {
    
    var delegate:DrawingCanvasViewDelegate?
    private var scrollView:UIScrollView
    private var containerView:UIView
    private var backgroundImageView:UIImageView
    private var canvasView:CanvasView
    private var drawing:Drawing
    
    init(drawing:Drawing) {
        self.drawing = drawing
        
        containerView = UIView(frame: CGRect(origin: CGPointZero, size: drawing.size()))
        
        scrollView = UIScrollView(frame: CGRect(origin: CGPointZero, size: drawing.size()))
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollView.minimumZoomScale = 1.00
        scrollView.maximumZoomScale = 4.00
        scrollView.scrollsToTop = false
        scrollView.addSubview(containerView)
        
        backgroundImageView = UIImageView(frame: CGRect(origin: CGPointZero, size: drawing.size()))
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImageView.image = drawing.backgroundImage
        containerView.addSubview(backgroundImageView)
        
        canvasView = CanvasView(frame: CGRect(origin: CGPointZero, size: drawing.size()), lines:drawing.lines)
        canvasView.backgroundColor = UIColor.clearColor()
        canvasView.layer.borderColor = UIColor.lightGrayColor().CGColor
        canvasView.layer.borderWidth = 0.5
        containerView.addSubview(canvasView)
        
        super.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: drawing.width, height: drawing.height)))
        
        scrollView.delegate = self
        addSubview(scrollView)
        canvasView.delegate = self
    }
    
    override init(frame: CGRect) {
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
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        containerView.addSubview(backgroundImageView)
        
        canvasView = CanvasView(frame: CGRect(origin: CGPointZero, size: frame.size))
        canvasView.backgroundColor = UIColor.clearColor()
        canvasView.layer.borderColor = UIColor.lightGrayColor().CGColor
        canvasView.layer.borderWidth = 0.5
        containerView.addSubview(canvasView)
        
        super.init(frame: frame)
        
        scrollView.delegate = self
        addSubview(scrollView)
        canvasView.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
    // MARK: CanvasViewDelegate
    
    func updatedUndoRedoCounts(undoCount: Int) {
        if let delegate = delegate {
            delegate.updatedUndoRedoCounts(undoCount)
        }
    }
    
    func willForceDrawAllLines(background: Bool) {
        hidden = true
    }
    
    func didForceDrawAllLines(background: Bool) {
        hidden = false
    }
    
    // MARK: Function
    
    func setBackgroundImage(image:UIImage) {
        drawing.backgroundImage = image
        backgroundImageView.image = image
    }
    
    func setCurrentColor(color:UIColor) {
        canvasView.currentColor = color
    }
    
    func setCurrentLineWidth(lineWidth:CGFloat) {
        canvasView.currentLineWidth = lineWidth
    }
    
    func clear()
    {
        canvasView.clear()
    }
    
    func back()
    {
        canvasView.back()
    }
    
    func forceDrawAllLines () {
        canvasView.forceDrawAllLines(true)
    }
}