//
//  ViewController.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/4/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import UIKit

class DrawingsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    var collectionView:UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = (view.frame.size.width - 60.0)/3
        flowLayout.itemSize = CGSize(width: width, height: 100)
        flowLayout.sectionInset = UIEdgeInsets(top:15.0, left: 15.0, bottom: 15.0, right: 15.0)
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: flowLayout)
        collectionView?.frame = view.frame;
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.alwaysBounceVertical = true
        view.addSubview(collectionView!)
        
        let drawBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "compose")
        navigationItem.rightBarButtonItem = drawBarButtonItem
        let darkInfoButton = UIButton(type: UIButtonType.InfoDark)
        darkInfoButton.addTarget(self, action: "info", forControlEvents: UIControlEvents.TouchUpInside)
        let infoBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: darkInfoButton)
        navigationItem.leftBarButtonItem = infoBarButtonItem
        
        title = "Drawmoji"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        cell.contentView.layer.borderColor = UIColor.redColor().CGColor
        cell.contentView.layer.borderWidth = 1.0
        return cell;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        /// Binary
        
//                let path = NSBundle.mainBundle().pathForResource("test591579072", ofType:"ibdr")
//                let data = NSData(contentsOfFile:path!)
//                let drawing = Drawing.parseBinaryDrawingFromData(data!)
//        
//                let drawingPlayerController = DrawingPlayerViewController(drawing: drawing)
//                presentViewController(UINavigationController.init(rootViewController: drawingPlayerController), animated: true, completion: nil)
        
        ///// JSON
        
                let path = NSBundle.mainBundle().pathForResource("5625b4a3e66a33ac020041b0", ofType:"ibdr")
                let image = UIImage(named: "12084f92af826bd96cc72fb19a829a3e")
                let JSONData = NSData(contentsOfFile:path!)
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(JSONData!, options:NSJSONReadingOptions(rawValue: 0))
                    let drawing = Drawing.parseLegacyDrawingFromJson(JSON["paths"] as! NSArray, height: JSON["height"] as! NSInteger, width: JSON["width"] as! NSInteger, lineWidth: JSON["line_width"] as! CGFloat, image: image)
                    let drawingPlayerController = DrawingPlayerViewController(drawing: drawing)
                    presentViewController(UINavigationController.init(rootViewController: drawingPlayerController), animated: true, completion: nil)
                }
                catch let JSONError as NSError {
                    print("\(JSONError)")
                }
    }
    
    func compose() {
        ///// Binary
        
//        let path = NSBundle.mainBundle().pathForResource("test591579072", ofType:"ibdr")
//        let data = NSData(contentsOfFile:path!)
//        let drawing = Drawing.parseBinaryDrawingFromData(data!)
//        
//        let drawingController = DrawingViewController(drawing: drawing)
//        presentViewController(UINavigationController.init(rootViewController: drawingController), animated: true, completion: nil)
        
        ///// JSON
        
        let path = NSBundle.mainBundle().pathForResource("5625b4a3e66a33ac020041b0", ofType:"ibdr")
        let image = UIImage(named: "12084f92af826bd96cc72fb19a829a3e")
        let JSONData = NSData(contentsOfFile:path!)
        do {
            let JSON = try NSJSONSerialization.JSONObjectWithData(JSONData!, options:NSJSONReadingOptions(rawValue: 0))
            let drawing = Drawing.parseLegacyDrawingFromJson(JSON["paths"] as! NSArray, height: JSON["height"] as! NSInteger, width: JSON["width"] as! NSInteger, lineWidth: JSON["line_width"] as! CGFloat, image: image)
            let drawingController = DrawingViewController(drawing: drawing)
            presentViewController(UINavigationController.init(rootViewController: drawingController), animated: true, completion: nil)
        }
        catch let JSONError as NSError {
            print("\(JSONError)")
        }
        
        ///// Blank Canvas
        
//        presentViewController(UINavigationController.init(rootViewController:DrawingViewController(drawing: nil)), animated: true, completion: nil)
    }
    
    func info() {
        
    }
}

