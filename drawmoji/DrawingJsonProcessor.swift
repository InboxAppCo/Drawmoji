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
    class func decodeDrawingFromFile(paths:NSArray,height:NSInteger,width:NSInteger,lineWidth:CGFloat,image:UIImage?) -> Drawing? {
        let drawing:Drawing = Drawing()
        
        for path in paths {
            let line:Line = Line()
            let colorString:String = path["color"] as! String
            line.color = UIColor(hexString:colorString)
            line.lineWidth = lineWidth
            for point in path["points"] as! NSArray {
                let x = point[0] as! Double
                let y = point[1] as! Double
                line.addPointAtLocation(CGPoint(x: x, y: y))
            }
            drawing.lines.append(line)
        }
        
        drawing.height = height
        drawing.width = width
        drawing.backgroundImage = image
        
        return drawing
    }
}
