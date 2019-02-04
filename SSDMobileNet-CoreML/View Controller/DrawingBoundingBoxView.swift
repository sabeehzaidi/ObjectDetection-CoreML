//
//  DrawingBoundingBoxView.swift
//  SSDMobileNet-CoreML
//
//  Created by GwakDoyoung on 04/02/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import UIKit

class DrawingBoundingBoxView: UIView {
    
    public var predictedObjects: [DetectedObjectPrediction] = [] {
        didSet {
            self.drawBoxs(with: predictedObjects)
            self.setNeedsDisplay()
        }
    }
    
    func drawBoxs(with predictions: [DetectedObjectPrediction]) {
        subviews.forEach({ $0.removeFromSuperview() })
        
        for prediction in predictions {
            createLabelAndBox(prediction: prediction)
        }
    }
    
    func createLabelAndBox(prediction: DetectedObjectPrediction) {
        let color = UIColor(hue: CGFloat(prediction.classHue ?? 0),
                            saturation: 1, brightness: 1, alpha: 0.8)
        
        let bgRect = prediction.rect.scale(to: bounds.size)
        let bgView = UIView(frame: bgRect)
        bgView.layer.borderColor = color.cgColor
        bgView.layer.borderWidth = 4
        bgView.backgroundColor = UIColor.clear
        addSubview(bgView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        label.text = prediction.className
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.black
        label.backgroundColor = color
        label.sizeToFit()
        label.frame = CGRect(x: bgRect.origin.x, y: bgRect.origin.y - label.frame.height,
                             width: label.frame.width, height: label.frame.height)
        addSubview(label)
    }
}
