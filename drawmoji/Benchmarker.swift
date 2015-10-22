//
//  Benchmarker.swift
//  drawmoji
//
//  Created by Hani Shabsigh on 10/22/15.
//  Copyright © 2015 Hani Shabsigh. All rights reserved.
//

import CoreFoundation

class Benchmarker {
    
    private var startTime:CFAbsoluteTime?
    private var endTime:CFAbsoluteTime?
    
    init()
    {
        
    }
    
    func start()
    {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> CFAbsoluteTime
    {
        endTime = CFAbsoluteTimeGetCurrent()
        
        return duration!
    }
    
    private var duration:CFAbsoluteTime?
    {
        if let endTime = endTime, startTime = startTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}