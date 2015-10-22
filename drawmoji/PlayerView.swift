//
//  DrawingPlayerView.swift
//  binaryProcessor
//
//  Created by Hani Shabsigh on 10/13/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import UIKit

protocol PlayerViewDelegate:class
{
    func didUpdatePlaybackSpeed(multiplier:Int)
    func didFinishPlayback(image:UIImage)
}

class PlayerView:UIView
{
    weak var delegate:PlayerViewDelegate?
    
    private var drawing:Drawing
    
    private(set) var finishedImage:UIImage?
    
    private(set) var multiplier:Int = 1
    
    private var currentPointCount:Int = 0
    private var totalPointCount:Int = 0
    
    private var duration:Double = 0
    private var originalPointsPerFrame:Int = 0
    private var playbackPointsPerFrame:Int = 0
    
    private var displayLink:CADisplayLink?
    
    private(set) var isPaused:Bool = false
    private(set) var isPlaying:Bool = false
    private(set) var isFinishing:Bool = false
    
    private let drawingQueue = dispatch_queue_create("com.inboxtheapp.background.drawing.player.drawing", nil);
    private let finishingQueue = dispatch_queue_create("com.inboxtheapp.background.drawing.player.finishing", nil);
    
    /// A `CGContext` for drawing the last representation of lines no longer receiving updates into.
    private lazy var frozenContext: CGContext = {
        let scale = UIApplication.sharedApplication().delegate!.window!!.screen.scale
        var size = self.bounds.size
        
        size.width *= scale
        size.height *= scale
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), 8, 0, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        CGContextTranslateCTM(context, 0, size.height)
        CGContextScaleCTM(context, scale, -scale)
            
        return context!
    }()
    
    init(frame: CGRect, drawing:Drawing, finishedImage:UIImage?)
    {
        self.drawing = drawing
        self.finishedImage = finishedImage
        self.totalPointCount = drawing.pointCount()
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        self.duration = duration(totalPointCount)
        self.originalPointsPerFrame = pointsPerFrame(totalPointCount, duration:duration, frameRate: 60)
        self.playbackPointsPerFrame = self.originalPointsPerFrame
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Drawing
    
    func draw()
    {
        if isPlaying == false {
            return
        }
        
        dispatch_async(drawingQueue) {
            var newFrozenImage:CGImageRef?
            
            if self.currentPointCount < self.totalPointCount {
                for _ in 1...self.playbackPointsPerFrame {
                    let retval = self.drawing.lineForPoint(self.currentPointCount)
                    if let line = retval.0 {
                        line.drawPointInContext(retval.1, context:self.frozenContext)
                    }
                    self.currentPointCount++
                }
                
                newFrozenImage = CGBitmapContextCreateImage(self.frozenContext)
            } else {
                self.isPlaying = false
                self.isFinishing = false
                
                self.playbackPointsPerFrame = self.originalPointsPerFrame
                
                newFrozenImage = CGBitmapContextCreateImage(self.frozenContext)
                if let frozenImage = newFrozenImage {
                    self.finishedImage = UIImage(CGImage:frozenImage)
                    self.delegate?.didFinishPlayback(UIImage(CGImage:frozenImage))
                } else {
                    UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0);
                    self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
                    let newFrozenUIImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    self.finishedImage = newFrozenUIImage
                    self.delegate?.didFinishPlayback(newFrozenUIImage)
                }
            }
            
            if self.isPlaying {
                dispatch_async(dispatch_get_main_queue()) {
                    if let frozenImage = newFrozenImage {
                        self.layer.contents = frozenImage
                    }
                    
                    self.performSelector(Selector("draw"), withObject: nil, afterDelay: 0.020)
                }
            }
        }
    }
    
    private func finishDrawing()
    {
        if let image = finishedImage {
            self.layer.contents = image.CGImage
            self.isFinishing = false
        } else {
            //let benchmarker = Benchmarker()
            //benchmarker.start()
            createFinishedImage({ (image) -> Void in
                self.layer.contents = image
                self.isFinishing = false
                //print("finishDrawing() took \(benchmarker.stop()) seconds.")
            })
        }
    }
    
    typealias completionBlock = (image:CGImageRef) -> Void
    private func createFinishedImage(completion:completionBlock?)
    {
        dispatch_async(finishingQueue) {
            let retval = self.drawing.lineForPoint(self.currentPointCount)
            if let line = retval.0 {
                if let indexOf = self.drawing.lines.indexOf(line) {
                    for var index = indexOf; index < self.drawing.lines.count; index++ {
                        self.drawing.lines[index].drawLineInContext(self.frozenContext)
                    }
                    
                    self.currentPointCount = self.totalPointCount
                }
            }
            
            let newFrozenImage:CGImageRef? = CGBitmapContextCreateImage(self.frozenContext)
            
            dispatch_async(dispatch_get_main_queue()) {
                if let frozenImage = newFrozenImage {
                    self.finishedImage = UIImage(CGImage: frozenImage)
                    self.delegate?.didFinishPlayback(UIImage(CGImage: frozenImage))
                    completion?(image:frozenImage)
                } else {
                    UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0);
                    self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
                    let newFrozenUIImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    self.finishedImage = newFrozenUIImage
                    self.delegate?.didFinishPlayback(newFrozenUIImage)
                    completion?(image:newFrozenUIImage.CGImage!)
                }
            }
        }
    }
    
    // MARK: Public Functions
    
    func play()
    {
        if isFinishing {
            return
        }
        
        if !isPlaying {
            if isPaused {
                isPaused = false
                isPlaying = true
                draw()
            } else {
                self.currentPointCount = 0
                CGContextClearRect(self.frozenContext, bounds)
                layer.contents = nil
                playbackPointsPerFrame = originalPointsPerFrame
                multiplier = 1
                isPlaying = true
                draw()
            }
        }
    }
    
    func pause()
    {
        if isFinishing {
            return
        }
        
        if isPlaying {
            isPaused = true
            isPlaying = false
        } else {
            play()
        }
    }
    
    func stop()
    {
        if isFinishing {
            return
        }
        
        isPlaying = false
        self.currentPointCount = 0
        CGContextClearRect(self.frozenContext, bounds)
        layer.contents = nil
        playbackPointsPerFrame = originalPointsPerFrame
        multiplier = 1
        isPaused = false
    }
    
    func finish()
    {
        if isFinishing {
            return
        }
        
        isFinishing = true
        isPlaying = false
        finishDrawing()
        playbackPointsPerFrame = originalPointsPerFrame
        multiplier = 1
        isPaused = false
    }
    
    func fastForward(multiplier:Int)
    {
        if isFinishing {
            return
        }
        
        self.multiplier = self.multiplier * multiplier
        playbackPointsPerFrame = originalPointsPerFrame * self.multiplier
        delegate?.didUpdatePlaybackSpeed(self.multiplier)
        if isPlaying == false {
            isPaused = true
            play()
        }
    }
    
    private func duration(pointCount:Int) -> Double
    {
        var duration:Double = 0.0
        switch pointCount {
        case _ where pointCount < 30:
            duration = Double(pointCount/30)
            break
        case _ where pointCount < 120:
            duration = 1.0
            break
        case _ where pointCount < 240:
            duration = 2.0
            break
        case _ where pointCount < 360:
            duration = 3.0
            break
        case _ where pointCount < 480:
            duration = 4.0
            break
        case _ where pointCount < 600:
            duration = 5.0
            break
        case _ where pointCount < 720:
            duration = 6.0
            break
        default:
            duration = 6.5
            break
        }
        return duration
    }
    
    private func pointsPerFrame(pointCount:Int, duration:Double, frameRate:Int) -> Int
    {
        return pointCount / Int(duration * Double(frameRate));
    }
    
    deinit {
        
    }
}
