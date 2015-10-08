//
//  DrawingOptionsViewController.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/4/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import UIKit

class DrawingOptionsViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        let cancelBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        title = "Where to start?"
        
        let width:Double = (Double(view.frame.size.width) - 60.0)/3
        let height:Double = 100.0
        let y = Double(view.frame.size.height)/2.0 - (height/2)
        let x1:Double = 15.0
        let x2:Double = 15.0 * 2 + width * 1
        let x3:Double = 15.0 * 3 + width * 2
        
        let galleryButton = UIButton(frame: CGRect(x: x1, y: y, width: width, height: height))
        galleryButton.setTitle("Gallery", forState: UIControlState.Normal)
        galleryButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        galleryButton.layer.borderColor = UIColor.blackColor().CGColor
        galleryButton.layer.borderWidth = 1
        galleryButton.addTarget(self, action: "gallery", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(galleryButton)
        
        let webButton = UIButton(frame: CGRect(x: x2, y: y, width: width, height: height))
        webButton.setTitle("Web", forState: UIControlState.Normal)
        webButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        webButton.layer.borderColor = UIColor.blackColor().CGColor
        webButton.layer.borderWidth = 1
        webButton.addTarget(self, action: "web", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(webButton)
        
        let canvasButton = UIButton(frame: CGRect(x: x3, y: y, width: width, height: height))
        canvasButton.setTitle("Canvas", forState: UIControlState.Normal)
        canvasButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        canvasButton.layer.borderColor = UIColor.blackColor().CGColor
        canvasButton.layer.borderWidth = 1
        canvasButton.addTarget(self, action: "canvas", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(canvasButton)
    }
    
    func cancel()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func gallery()
    {
        let drawingViewController = DrawingViewController()
        navigationController?.pushViewController(drawingViewController, animated: true)
    }
    
    func web ()
    {
        let drawingViewController = DrawingViewController()
        navigationController?.pushViewController(drawingViewController, animated: true)
    }
    
    func canvas ()
    {
        let drawingViewController = DrawingViewController()
        navigationController?.pushViewController(drawingViewController, animated: true)
    }
}
