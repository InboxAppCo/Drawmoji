//
//  DrawingPlayerViewController.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/4/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import UIKit

class DrawingPlayerViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        let cancelBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        let backBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
        title = "Watch"
    }
    
    func cancel()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
