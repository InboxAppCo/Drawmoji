//
//  DrawingDocument.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/21/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import Foundation
import UIKit

class DrawingDocument:UIDocument
{
    let EXTENSION = "drawing"
    private let DATA_FILENAME = "drawing.data"
    private let METADATA_FILENAME = "drawing.metadata"
    
    private var drawingData:Drawing?
    private var drawingMetadata:DrawingMetadata?
    
    private var fileWrapper:NSFileWrapper?
    
    override func contentsForType(typeName: String) throws -> AnyObject
    {
        var wrappers = [String:NSFileWrapper]()
        wrappers[DATA_FILENAME] = encodeObject(drawingData!)
        wrappers[METADATA_FILENAME] = encodeObject(drawingMetadata!)
        return NSFileWrapper(directoryWithFileWrappers:wrappers)
    }
    
    func encodeObject(object:AnyObject) -> NSFileWrapper
    {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData:data)
        archiver.encodeObject(object, forKey: "data")
        archiver.finishEncoding()
        return NSFileWrapper(regularFileWithContents:data)
    }
    
    func decodeObjectFromWrapper(filename:String) -> AnyObject?
    {
        let fw = fileWrapper?.fileWrappers?[filename]
        if let theFw = fw {
            let data = theFw.regularFileContents
            if let theData = data {
                let unarchiver = NSKeyedUnarchiver.init(forReadingWithData:theData)
                return unarchiver.decodeObjectForKey("data")
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func getData() -> Drawing?
    {
        if let data = drawingData {
            return data
        } else {
            drawingData = decodeObjectFromWrapper(DATA_FILENAME) as? Drawing
            return drawingData
        }
    }
    
    func getMetadata() -> DrawingMetadata?
    {
        if let metadata = drawingMetadata {
            return metadata
        } else {
            drawingMetadata = decodeObjectFromWrapper(METADATA_FILENAME) as? DrawingMetadata
            return drawingMetadata
        }
    }
    
    override func loadFromContents(contents: AnyObject, ofType typeName: String?) throws
    {
        self.fileWrapper = contents as? NSFileWrapper
    }
}