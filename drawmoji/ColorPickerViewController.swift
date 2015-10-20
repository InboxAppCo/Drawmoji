//
//  ColorPickerViewController.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/5/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import UIKit

protocol ColorPickerViewControllerDelegate:class {
    func colorSelectionChanged(color:UIColor)
}

class ColorPickerViewController:UIViewController, UITableViewDataSource, UITableViewDelegate{
    let tableView = UITableView()
    weak var delegate:ColorPickerViewControllerDelegate?
    
    let colors:[UIColor] = [UIColor.blackColor(),UIColor.darkGrayColor(),UIColor.lightGrayColor(),UIColor.whiteColor(),UIColor.grayColor(),UIColor.redColor(),UIColor.greenColor(),UIColor.blueColor(),UIColor.cyanColor(),UIColor.yellowColor(),UIColor.magentaColor(),UIColor.orangeColor(),UIColor.purpleColor(),UIColor.brownColor(),UIColor.clearColor()]
    let titles:[String] = ["Black","Dark Gray","Light Gray","White","Gray","Red","Green","Blue","Cyan","Yellow","Magenta","Orange","Purple","Brown","Eraser"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.frame
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        title = "Pick a Color"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        let colorView = UIView(frame: CGRect(x:0, y:0, width: 20, height: 20))
        colorView.layer.cornerRadius = 10.0
        colorView.clipsToBounds = true
        colorView.layer.borderColor = UIColor.lightGrayColor().CGColor
        colorView.layer.borderWidth = 2.0
        colorView.backgroundColor = colors[indexPath.row]
        cell.accessoryView = colorView
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.colorSelectionChanged(colors[indexPath.row])
        dismissViewControllerAnimated(true, completion: nil)
    }
}
