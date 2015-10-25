/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The primary view controller that hosts a `CanvasView` for the user to interact with.
*/

import UIKit

class DrawingViewController: UIViewController, UIToolbarDelegate, ColorPickerViewControllerDelegate, SizePickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DrawingCanvasViewDelegate {
    // MARK: Properties
    
    var imagePicker:UIImagePickerController? = nil
    var topToolbar:UIToolbar = UIToolbar()
    var bottomToolbar:UIToolbar = UIToolbar()
    private var drawingCanvasView:DrawingCanvasView?
    private var drawing:Drawing?
    var undoCountButton:UIBarButtonItem?
    var undoButton:UIBarButtonItem?
    var redoButton:UIBarButtonItem?
    var redoCountButton:UIBarButtonItem?
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    // MARK: Inititialization
    
    internal init(drawing:Drawing?) {
        self.drawing = drawing
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        if let drawing = drawing {
            let size = CGSizeMake(view.frame.size.width, view.frame.size.height - 152)
            let newDrawing = Drawing.aspectFitDrawingInSize(drawing, size:size)
            
            let x = (size.width - CGFloat(newDrawing.width))/2
            let y = (size.height - CGFloat(newDrawing.height))/2 + 108
            drawingCanvasView = DrawingCanvasView(drawing: newDrawing, frame: CGRect(x: x, y: y, width: CGFloat(newDrawing.width), height: CGFloat(newDrawing.height)))
        } else {
            drawingCanvasView = DrawingCanvasView(frame: CGRect(x: 0, y: 108, width: view.frame.size.width, height: view.frame.size.height-152))
        }
        view.addSubview(drawingCanvasView!)
        drawingCanvasView!.delegate = self
        drawingCanvasView!.forceDrawAllLines()
        
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
        
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y + 44)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.hidden = true
        view.addSubview(activityIndicator)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.allowsEditing = false
    }
    
    // MARK: Actions
    
    func clearView(sender: UIBarButtonItem) {
        drawingCanvasView?.clear()
    }
    
    func undo(sender: UIBarButtonItem) {
        drawingCanvasView?.undo()
    }
    
    func undoAll(sender: UIBarButtonItem) {
        drawingCanvasView?.undoAll()
    }
    
    func redo(sender: UIBarButtonItem) {
        drawingCanvasView?.redo()
    }
    
    func redoAll(sender: UIBarButtonItem) {
        drawingCanvasView?.redoAll()
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
//        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
//        let writePath = documents.stringByAppendingPathComponent("file.plist")
//        
//        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
//        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"image.png"]; //Add the file name
//        [pngData writeToFile:filePath atomically:YES]; //Write the file
    }
    
    func photo(sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let photoAction = UIAlertAction(title: "Take Photo", style: .Default) { (action) in
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            }
            alertController.addAction(photoAction)
        }
        
        let galleryAction = UIAlertAction(title: "Choose Photo", style: .Default) { (action) in
            self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.presentViewController(self.imagePicker!, animated: true, completion: nil)
        }
        alertController.addAction(galleryAction)
        
        let searchAction = UIAlertAction(title: "Search Web", style: .Default) { (action) in
            
        }
        alertController.addAction(searchAction)
        
        if let _ = drawingCanvasView?.getDrawing().backgroundImage {
            let removeAction = UIAlertAction(title: "Remove Background", style: .Default) { (action) in
                self.drawingCanvasView?.setBackgroundImage(nil)
            }
            alertController.addAction(removeAction)
        }
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    func share(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let galleryAction = UIAlertAction(title: "Image", style: .Default) { (action) in
            if let drawing = self.drawingCanvasView?.getDrawing() {
                let image = DrawingToMediaProcessor.imageFromDrawing(drawing)
                
                let activity = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
                
                self.presentViewController(activity, animated: true, completion: nil)
            }
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
        if (CGColorGetAlpha(color.CGColor) == 0){
            drawingCanvasView?.setCurrentBrushType(.Eraser)
        } else {
            drawingCanvasView?.setCurrentBrushType(.Pencil)
        }
        drawingCanvasView?.setCurrentColor(color)
    }
    
    // MARK: SizePickerViewControllerDelegate
    
    func sizeSelectionChanged(size: CGFloat) {
        drawingCanvasView?.setCurrentLineWidth(size)
    }
    
    // MARK: DrawingCanvasViewDelegate
    
    func drawingCanvasView(drawingCanvasView: DrawingCanvasView, didUpdateUndoCount: Int, redoCount: Int) {
        if didUpdateUndoCount > 0 {
            undoButton?.enabled = true
            undoCountButton?.title = "\(didUpdateUndoCount)"
        } else {
            undoButton?.enabled = false
            undoCountButton?.title = ""
        }
        
        if redoCount > 0 {
            redoButton?.enabled = true
            redoCountButton?.title = "\(redoCount)"
        } else {
            redoButton?.enabled = false
            redoCountButton?.title = ""
        }
    }
    
    func drawingCanvasViewWillBeginForceDrawingAllLines(drawingCanvasView: DrawingCanvasView) {
        drawingCanvasView.hidden = true
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
    }
    
    func drawingCanvasViewDidFinishForceDrawingAllLines(drawingCanvasView: DrawingCanvasView) {
        activityIndicator.stopAnimating()
        drawingCanvasView.hidden = false
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        drawingCanvasView?.setBackgroundImage(image)
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
        undoCountButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "undoAll:")
        undoCountButton?.width = 20.0
        topToolbarButtons.append(undoCountButton!)
        undoButton = UIBarButtonItem(barButtonSystemItem: .Rewind, target: self, action: "undo:")
        undoButton?.enabled = false
        topToolbarButtons.append(undoButton!)
        topToolbarButtons.append(fixedSpaceBarButtonItem)
        //topToolbarButtons.append(UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "play:"))
        //topToolbarButtons.append(fixedSpaceBarButtonItem)
        redoButton = UIBarButtonItem(barButtonSystemItem: .FastForward, target: self, action: "redo:")
        redoButton?.enabled = false
        topToolbarButtons.append(redoButton!)
        redoCountButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "redoAll:")
        redoCountButton?.width = 20.0
        topToolbarButtons.append(redoCountButton!)
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
    
    deinit {
        print("DrawingViewController deinit")
    }
}
