//
//  Drawing.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/5/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import Foundation
import UIKit

class Drawing:NSObject {
    
    var paths:[Line] = [Line]()
    var height:Int?
    var width:Int?
    var backgroundImage:UIImage?
    
    class func parseLegacyDrawingFromJson(paths:NSArray,height:Int,width:Int,lineWidth:Float,image:UIImage) -> Drawing? {
        if let theDrawing = DrawingJsonProcessor.decodeDrawingFromFile(paths, height: height, width: width, lineWidth: lineWidth, image: image) {
            return theDrawing
        } else {
            return nil
        }
    }
    
//    class func writeDrawingToFile(drawing:Drawing,file:NSData,legacy:Bool) -> Bool {
//        if legacy {
//            
//        } else {
//            
//        }
//    }
}
