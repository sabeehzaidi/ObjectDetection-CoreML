//
//  MLMultiArray+SSDMobileNet.swift
//  SSDMobileNet-CoreML
//
//  Created by GwakDoyoung on 01/02/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import CoreML

struct DetectedObjectPrediction {
    let confidence: Double
    let classIndex: Int // max 91
    let anchorIndex: Int // max 1917
    let rect: CGRect
    var className: String? = nil
    var classHue: Double? = nil
}

extension MLMultiArray {
    /*
     # Usage
     `boxPredictions[[0, 0, 0, 0, 1]]`
     */
    subscript(indices: [Int]) -> NSNumber? {
        guard indices.count == self.shape.count else { return nil }
        let indices: [NSNumber] = indices as [NSNumber]
        return self[indices]
    }
    
    subscript(classIndex: Int, anchorIndex: Int) -> NSNumber? {
        return self[classIndex*shape[4].intValue + anchorIndex]
    }
}

struct Math {
    static func sigmoid(_ val:Double) -> Double {
        return 1.0/(1.0 + exp(-val))
    }
}
