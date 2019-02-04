//
//  Hyperparameter+UI.swift
//  SSDMobileNet-CoreML
//
//  Created by GwakDoyoung on 05/02/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import Foundation

struct Hyperparameter {
    // The threshold using on prunning results
    static let confidenceThreshold: Double = 0.0 // sigmoid(0.0) == 0.5
    // The threshold using 'interaction on union' on duplicated box
    static let IOUThreshold: Float = 0.3
}
