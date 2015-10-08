/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The primary view controller that hosts a `CanvasView` for the user to interact with.
*/

import UIKit

class DrawingViewController: UIViewController, UIToolbarDelegate, ColorPickerViewControllerDelegate, SizePickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: Properties
    
    var topToolbar:UIToolbar = UIToolbar()
    var bottomToolbar:UIToolbar = UIToolbar()
    let imagePicker = UIImagePickerController()
    var drawingCanvasView:DrawingCanvasView?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        let cancelBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        title = "Draw"
        
        navigationItem.hidesBackButton = true
        
        navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        automaticallyAdjustsScrollViewInsets = false
        
        drawingCanvasView = DrawingCanvasView(frame: CGRect(x: 0, y: 108, width: view.frame.size.width, height: view.frame.size.height-152))
        view.addSubview(drawingCanvasView!)
        
        imagePicker.delegate = self
        
        topToolbar.frame = CGRect(x: 0, y: 64, width: view.frame.size.width, height: 44)
        topToolbar.delegate = self
        view.addSubview(topToolbar)
        
        setTopToolbarButtonItemsForPlaying(false)
        
        bottomToolbar.frame = CGRect(x: 0, y: view.frame.size.height-44, width: view.frame.size.width, height: 44)
        view.addSubview(bottomToolbar)
        
        var bottomToolbarButtons = [UIBarButtonItem]()
        bottomToolbarButtons.append(UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "save:"))
        bottomToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        bottomToolbarButtons.append(UIBarButtonItem(title: "Photo", style: .Plain, target: self, action: "photo:"))
        bottomToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        bottomToolbarButtons.append(UIBarButtonItem(title: "Share", style: .Plain, target: self, action: "share:"))
        bottomToolbar.setItems(bottomToolbarButtons, animated:false)
    }
    
    // MARK: Actions
    
    func clearView(sender: UIBarButtonItem) {
        drawingCanvasView?.canvasView.clear()
    }
    
    func back(sender: UIBarButtonItem) {
        drawingCanvasView?.canvasView.back()
    }
    
    func play(sender: UIBarButtonItem) {
        UIView.animateWithDuration(1.5) { () -> Void in
            self.view.backgroundColor = UIColor.darkGrayColor()
        }
        setTopToolbarButtonItemsForStopping(true)
    }
    
    func stop(sender: UIBarButtonItem) {
        UIView.animateWithDuration(1) { () -> Void in
            self.view.backgroundColor = UIColor.whiteColor()
        }
        setTopToolbarButtonItemsForPlaying(true)
    }
    
    func forward(sender: UIBarButtonItem) {
        drawingCanvasView?.canvasView.forward()
    }
    
    func changeColor(sender: UIBarButtonItem) {
        let colorPickerVC = ColorPickerViewController()
        colorPickerVC.delegate = self
        let navVC = UINavigationController(rootViewController: colorPickerVC)
        presentViewController(navVC, animated: true, completion: nil)
    }
    
    func changeSize(sender: UIBarButtonItem) {
        let sizePickerVC = SizePickerViewController()
        sizePickerVC.delegate = self
        let navVC = UINavigationController(rootViewController: sizePickerVC)
        presentViewController(navVC, animated: true, completion: nil)
    }
    
    func save(sender: UIBarButtonItem) {
        
    }
    
    func photo(sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let photoAction = UIAlertAction(title: "Take Photo", style: .Default) { (action) in
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(photoAction)
        }
        
        let galleryAction = UIAlertAction(title: "Choose Photo", style: .Default) { (action) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(galleryAction)
        
        let searchAction = UIAlertAction(title: "Search Web", style: .Default) { (action) in
            
        }
        alertController.addAction(searchAction)
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func share(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let galleryAction = UIAlertAction(title: "Image", style: .Default) { (action) in
            
        }
        alertController.addAction(galleryAction)
        
        let searchAction = UIAlertAction(title: "Video", style: .Default) { (action) in
            
        }
        alertController.addAction(searchAction)
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Rotation
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait]
    }
    
    // MARK: UIToolbarDelegate
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.Top
    }
    
    // MARK: ColorPickerViewControllerDelegate
    
    func colorSelectionChanged(color: UIColor) {
        drawingCanvasView?.canvasView.color = color
    }
    
    // MARK: SizePickerViewControllerDelegate
    
    func sizeSelectionChanged(size: CGFloat) {
        drawingCanvasView?.canvasView.size = size
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        drawingCanvasView?.backgroundImageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Bar Button Items
    
    func setTopToolbarButtonItemsForPlaying(animated:Bool) {
        let fixedSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        fixedSpaceBarButtonItem.width = 15.0
        
        var topToolbarButtons = [UIBarButtonItem]()
        topToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "clearView:"))
        topToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        topToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .Rewind, target: self, action: "back:"))
        //topToolbarButtons.append(fixedSpaceBarButtonItem)
        //topToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "play:"))
        topToolbarButtons.append(fixedSpaceBarButtonItem)
        topToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FastForward, target: self, action: "forward:"))
        topToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        topToolbarButtons.append(UIBarButtonItem(title: "Size", style: .Plain, target: self, action: "changeSize:"))
        topToolbarButtons.append(UIBarButtonItem(title: "Color", style: .Plain, target: self, action: "changeColor:"))
        topToolbar.setItems(topToolbarButtons, animated: animated)
    }
    
    func setTopToolbarButtonItemsForStopping(animated:Bool) {
        var topToolbarButtons = [UIBarButtonItem]()
        topToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        topToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "stop:"))
        topToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        topToolbar.setItems(topToolbarButtons, animated: animated)
    }
}
