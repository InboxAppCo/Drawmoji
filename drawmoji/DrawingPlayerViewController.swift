//
//  DrawingPlayerViewController.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/4/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import UIKit

class DrawingPlayerViewController: UIViewController, DrawingPlayerViewDelegate
{
    private var bottomToolbar:UIToolbar = UIToolbar()
    private var drawingPlayerView:DrawingPlayerView?
    private var drawing:Drawing?
    private var scrollView:UIScrollView?
    var speedButton:UIBarButtonItem?
    
    // MARK: Inititialization
    
    internal init(drawing:Drawing?) {
        self.drawing = drawing
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        let cancelBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        let backBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
        title = "Watch"
        
        scrollView = UIScrollView(frame: CGRect(origin: CGPointZero, size: CGSize(width: view.bounds.size.width, height: view.bounds.size.height-44)))
        scrollView?.alwaysBounceVertical = true
        scrollView?.contentSize = CGSize(width: view.bounds.width, height: 2000)
        view.addSubview(scrollView!)
        
        if let drawing = drawing {
            let size = CGSizeMake(view.frame.size.width, view.frame.size.height - 108)
            let newDrawing = Drawing.aspectFitDrawingInSize(drawing, size:size)
            
            let x = (size.width - CGFloat(newDrawing.width))/2
            let y = (size.height - CGFloat(newDrawing.height))/2
            drawingPlayerView = DrawingPlayerView(drawing: newDrawing, frame: CGRect(x: x, y: y, width: CGFloat(newDrawing.width), height: CGFloat(newDrawing.height)), finishedImage:nil)
        } else {
            drawingPlayerView = DrawingPlayerView(frame: CGRect(x: 0, y: 108, width: view.frame.size.width, height: view.frame.size.height-152))
        }
        drawingPlayerView?.delegate = self
        scrollView?.addSubview(drawingPlayerView!)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.drawingPlayerView!.addGestureRecognizer(gestureRecognizer)
        
        bottomToolbar.frame = CGRect(x: 0, y: view.frame.size.height-44, width: view.frame.size.width, height: 44)
        view.addSubview(bottomToolbar)
        
        var bottomToolbarButtons = [UIBarButtonItem]()
        bottomToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        bottomToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play, target: self, action: "play:"))
        bottomToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        bottomToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause, target: self, action: "pause:"))
        bottomToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        bottomToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FastForward, target: self, action: "fastForward:"))
        speedButton = UIBarButtonItem(title: "1", style: UIBarButtonItemStyle.Plain, target:nil, action:nil)
        bottomToolbarButtons.append(speedButton!)
        bottomToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        bottomToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "stop:"))
        bottomToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        bottomToolbarButtons.append(UIBarButtonItem(title: "Finish", style: UIBarButtonItemStyle.Plain, target: self, action: "finish:"))
        bottomToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        bottomToolbar.setItems(bottomToolbarButtons, animated:false)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        drawingPlayerView!.play()
//        drawingPlayerView!.finish()
    }
    
    override func viewDidDisappear(animated: Bool)
    {
         super.viewDidDisappear(animated)
        
        drawingPlayerView!.stop()
    }
    
    func cancel()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleTap(gestureRecognizer: UIGestureRecognizer)
    {
        if drawingPlayerView!.isPlaying() {
            drawingPlayerView!.finish()
//            drawingPlayerView!.fastForward(10)
        } else {
            drawingPlayerView!.play()
        }
    }
    
    func play(sender: UIBarButtonItem)
    {
        drawingPlayerView?.play()
    }
    
    func pause(sender: UIBarButtonItem)
    {
        drawingPlayerView?.pause()
    }
    
    func fastForward(sender: UIBarButtonItem)
    {
        drawingPlayerView?.fastForward(10)
    }
    
    func stop(sender: UIBarButtonItem)
    {
        drawingPlayerView?.stop()
    }
    
    func finish(sender: UIBarButtonItem)
    {
        drawingPlayerView?.finish()
    }
    
    // MARK: DrawingCanvasViewDelegate
    
    func didUpdatePlaybackSpeed(multiplier: Int)
    {
        speedButton?.title = "\(multiplier)"
    }
    
    func didFinishPlayback(image: UIImage)
    {
        print("didFinishPlayback")
    }
    
    // MARK: deinit
    
    deinit {
        print("DrawingPlayerViewController deinit")
    }
}
