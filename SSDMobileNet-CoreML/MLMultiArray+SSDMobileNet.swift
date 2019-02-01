//
//  MLMultiArray+SSDMobileNet.swift
//  SSDMobileNet-CoreML
//
//  Created by GwakDoyoung on 01/02/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import CoreML

extension MLMultiArray {
    /*
     # Usage
     `boxPredictions[[0, 0, 0, 0, 1]]`
     */
    subscript(indices: [Int]) -> NSNumber? {
        guard indices.count != self.shape.count else { return nil }
        let indices: [NSNumber] = indices as [NSNumber]
        return self[indices]
    }
    
    /*
     [1, 1, 91, 1, 1917]
     [1, 1, 4, 1, 1917]
     */
}
