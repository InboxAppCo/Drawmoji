//
//  DrawingCanvasView.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/6/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import UIKit

class DrawingCanvasView:UIView, UIScrollViewDelegate
{
    var scrollView:UIScrollView = UIScrollView()
    var backgroundImageView:UIImageView = UIImageView()
    var canvasView:CanvasView = CanvasView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView.frame = CGRect(origin: CGPointZero, size: bounds.size)
        scrollView.delegate = self
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollView.minimumZoomScale = 1.00
        scrollView.maximumZoomScale = 4.00
        scrollView.scrollsToTop = false
        addSubview(scrollView)
        
        backgroundImageView.frame = CGRect(origin: CGPointZero, size: bounds.size)
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        scrollView.addSubview(backgroundImageView)
        
        canvasView.frame = CGRect(origin: CGPointZero, size: bounds.size)
        canvasView.backgroundColor = UIColor.clearColor()
        canvasView.layer.borderColor = UIColor.lightGrayColor().CGColor
        canvasView.layer.borderWidth = 0.5
        scrollView.addSubview(canvasView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
}