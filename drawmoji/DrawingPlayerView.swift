//
//  DrawingPlayerView.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/19/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import UIKit

@objc protocol DrawingPlayerViewDelegate:class
{
    optional func didUpdatePlaybackSpeed(multiplier:Int)
    optional func didFinishPlayback(image: UIImage)
}

class DrawingPlayerView:UIView
{
    private(set) var backgroundImageView:UIImageView
    private var playerView:PlayerView
    var drawing:Drawing
    private var hiddenDelegate:DrawingPlayerViewDelegateHandler?
    weak var delegate:DrawingPlayerViewDelegate?
    
    init(drawing:Drawing, frame:CGRect, finishedImage:UIImage?)
    {
        self.drawing = drawing
        
        backgroundImageView = UIImageView(frame: CGRect(origin: CGPointZero, size: frame.size))
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFit
        backgroundImageView.clipsToBounds = true
        backgroundImageView.image = drawing.backgroundImage
        
        playerView = PlayerView(frame: CGRect(origin:CGPointZero, size:frame.size), drawing:drawing, finishedImage:finishedImage)
        playerView.backgroundColor = UIColor.clearColor()

        super.init(frame:frame)
        
        addSubview(backgroundImageView)
        addSubview(playerView)
        hiddenDelegate = DrawingPlayerViewDelegateHandler(outer: self)
        playerView.delegate = hiddenDelegate
    }
    
    override init(frame: CGRect)
    {
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isPlaying() -> Bool
    {
        return playerView.isPlaying
    }
    
    func play()
    {
        playerView.play()
    }
    
    func pause()
    {
        playerView.pause()
    }
    
    func stop()
    {
        playerView.stop()
    }
    
    func finish()
    {
        playerView.finish()
    }
    
    func fastForward(multiplier:Int)
    {
        playerView.fastForward(multiplier)
    }
    
    var multiplier:Int
    {
        return playerView.multiplier
    }
    
    var finishedImage:UIImage?
    {
        return playerView.finishedImage
    }
    
    deinit {
        
    }
}

private class DrawingPlayerViewDelegateHandler:NSObject, PlayerViewDelegate {
    
    private weak var outer:DrawingPlayerView?
    
    init(outer:DrawingPlayerView)
    {
        self.outer = outer
        super.init()
    }
    
    // MARK: CanvasViewDelegate
    
    func didUpdatePlaybackSpeed(multiplier:Int)
    {
        outer?.delegate?.didUpdatePlaybackSpeed?(multiplier)
    }
    
    func didFinishPlayback(image:UIImage)
    {
        outer?.delegate?.didFinishPlayback?(image)
    }
}
