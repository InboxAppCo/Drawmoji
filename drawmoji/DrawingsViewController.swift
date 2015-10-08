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
        presentViewController(UINavigationController.init(rootViewController: DrawingPlayerViewController()), animated: true, completion: nil)
    }
    
    func compose() {
        presentViewController(UINavigationController.init(rootViewController: DrawingViewController()), animated: true, completion: nil)
    }
    
    func info() {
        
    }
}
