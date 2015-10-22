//
//  DrawingJsonProcessor.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/5/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import Foundation
import UIKit

class DrawingJsonProcessor
{
    class func decodeDrawingFromData(data:NSData, image:UIImage?) -> Drawing?
    {
        do {
            let parsed = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
            
            let drawing:Drawing = Drawing()
            
            let paths = parsed["paths"] as! [[String:AnyObject]]
            
            let lineWidth = CGFloat(parsed["line_width"] as! Float)
            
            for path in paths {
                let line:Line = Line()
                let colorString:String = path["color"] as! String
                line.color = UIColor(hexString:colorString)
                line.lineWidth = lineWidth
                line.brushType = 1
                for point in path["points"] as! [AnyObject] {
                    let x = point[0] as! Double
                    let y = point[1] as! Double
                    line.addPointAtLocation(CGPoint(x: x, y: y))
                }
                drawing.lines.append(line)
            }
            
            drawing.width = parsed["width"] as! Int
            drawing.height = parsed["height"] as! Int
            drawing.backgroundImage = image
            
            return drawing
        }
        catch let error as NSError {
            print("A JSON parsing error occurred, here are the details:\n \(error)")
            return nil
        }
    }
    
    class func encodeDrawingToData(drawing:Drawing) -> NSData?
    {
        var json = [String:AnyObject]()
        
        json["line_width"] = 5
        json["width"] = drawing.width
        json["height"] = drawing.height

        var paths = [[String:AnyObject]]()
        for line in drawing.lines {
            var path = [String:AnyObject]()
            path["color"] = line.color.toHexString()
            var points = [[Double]]()
            for point in line.points {
                var newPoint = [Double]()
                newPoint.append(Double(point.x))
                newPoint.append(Double(point.y))
                points.append(newPoint)
            }
            path["points"] = points
            paths.append(path)
        }
        json["paths"] = paths
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(rawValue: 0))
            return data
        }
        catch let error as NSError {
            print("A JSON parsing error occurred, here are the details:\n \(error)")
            return nil
        }
    }
}
