//
//  SizePickerViewController.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/5/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import UIKit

protocol SizePickerViewControllerDelegate {
    func sizeSelectionChanged(size:CGFloat)
}

class SizePickerViewController:UIViewController, UITableViewDataSource, UITableViewDelegate{
    let tableView = UITableView()
    var delegate:SizePickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.frame
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        title = "Pick a Color"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 26
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        if indexPath.row == 0 {
            cell.textLabel?.text = "1"
        } else {
            let size:CGFloat = CGFloat(indexPath.row-1) * 10.0 + 5
            cell.textLabel?.text = "\(size)"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            delegate?.sizeSelectionChanged(1)
        } else {
            let size:CGFloat = CGFloat(indexPath.row-1) * 10.0 + 5
            delegate?.sizeSelectionChanged(size)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}
