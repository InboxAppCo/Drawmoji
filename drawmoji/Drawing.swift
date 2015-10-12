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
    
    var lines:[Line] = [Line]()
    var height:Int = 0
    var width:Int = 0
    var backgroundImage:UIImage?
    
    class func parseLegacyDrawingFromJson(paths:NSArray,height:NSInteger,width:NSInteger,lineWidth:CGFloat,image:UIImage?) -> Drawing? {
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
    
    func size() -> CGSize {
        return CGSize(width: width, height: height)
    }
}
