//
//  DrawingMetadata.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/21/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import Foundation
import UIKit

class DrawingMetadata:NSObject, NSCoding
{
    // MARK: Properties
    
    var thumbnail:UIImage?
    
    // MARK: Init
    
    override init()
    {
        
    }
    
    convenience init(thumbnail:UIImage?)
    {
        self.init()
        self.thumbnail = thumbnail
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        self.init()
        thumbnail = aDecoder.decodeObjectForKey("thumbnail") as? UIImage
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(thumbnail, forKey: "thumbnail")
    }
}
