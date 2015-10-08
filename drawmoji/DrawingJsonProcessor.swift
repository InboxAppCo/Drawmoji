//
//  DrawingJsonProcessor.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/5/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import Foundation
import UIKit

class DrawingJsonProcessor {
    class func decodeDrawingFromFile(paths:NSArray,height:Int,width:Int,lineWidth:Float,image:UIImage) -> Drawing? {
        let drawing:Drawing = Drawing()
        
        for path in paths {
            
        }
        
        drawing.height = height
        drawing.width = width
        drawing.backgroundImage = image
        
        return drawing
    }
}
