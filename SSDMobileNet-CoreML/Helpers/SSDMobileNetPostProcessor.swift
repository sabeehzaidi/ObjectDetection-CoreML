//
//  SSDMobileNetPostProcessor.swift
//  SSDMobileNet-CoreML
//
//  Created by GwakDoyoung on 04/02/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import CoreML

class SSDMobileNetPostProcessor {
    var classNames: [String]? = nil
    var classHues: [Double] = []
    
    init() {
        if let path = Bundle.main.path(forResource: "coco_labels_list", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                classNames = data.components(separatedBy: .newlines)
                if let classNames = classNames {
                    classHues = classNames.enumerated().map { Double($0.offset)/Double(classNames.count) }
                }
            } catch {
                print(error)
            }
        }
    }
    
    public func getClassName(from prediction: DetectedObjectPrediction) -> String? {
        return classNames?[prediction.classIndex]
    }
    
    public func convertToPredictions(from classResults: MLMultiArray, and boxResults: MLMultiArray) -> [DetectedObjectPrediction] {
        //
        let predictionsArray: [[DetectedObjectPrediction]] = filterNonZeroIndicesAndConvert(from: classResults, from: boxResults)
        //
        let predictions: [DetectedObjectPrediction] = filterNonInterectionAndFlat(from: predictionsArray)
        
        return predictions
    }
    
    private func filterNonZeroIndicesAndConvert(from classResults: MLMultiArray, from boxResults: MLMultiArray) -> [[DetectedObjectPrediction]] {
        let predictionCount: Int = Int(truncating: classResults.shape[4])   // 1917
        let onehoutCount: Int = Int(truncating: classResults.shape[2])      // 91
        
        var predictionsArray: [[DetectedObjectPrediction]] = Array(repeating: [], count: onehoutCount)
        for classIndex in 1..<onehoutCount {
            for anchorIndex in 0..<predictionCount {
                if let confidence = classResults[classIndex, anchorIndex]?.doubleValue,
                    confidence > Hyperparameter.confidenceThreshold {
                
                    let tValues = [
                        boxResults[0, anchorIndex],
                        boxResults[1, anchorIndex],
                        boxResults[2, anchorIndex],
                        boxResults[3, anchorIndex]
                        ].compactMap{ return $0?.doubleValue }
                    
                    let rect: CGRect = makeRect(with: tValues, on: Anchors.ssdAnchors[anchorIndex])
                    
                    predictionsArray[classIndex].append(DetectedObjectPrediction(confidence: confidence,
                                                                classIndex: classIndex,
                                                                anchorIndex: anchorIndex,
                                                                rect: rect,
                                                                className: classNames?[classIndex],
                                                                classHue: classHues[classIndex]))
                }
            }
        }
        
        return predictionsArray
    }
    
    private func makeRect(with tValues: [Double], on anchor: [Float32]) -> CGRect {
        // calculate anchor
        let anchorMinY = Double(anchor[0])
        let anchorMinX = Double(anchor[1])
        let anchorMaxY = Double(anchor[2])
        let anchorMaxX = Double(anchor[3])
        
        let anchorCenterY = (anchorMinY + anchorMaxY) / 2.0
        let anchorCenterX = (anchorMinX + anchorMaxX) / 2.0
        let anchorHeight = (anchorMaxY - anchorMinY)
        let anchorWidth = (anchorMaxX - anchorMinX)
        
        // calculate predicted box
        let ty = tValues[0] / 10.0
        let tx = tValues[1] / 10.0
        let th = tValues[2] / 5.0
        let tw = tValues[3] / 5.0
        
        let width = exp(tw) * anchorWidth
        let height = exp(th) * anchorHeight
        
        let centerY = ty * anchorHeight + anchorCenterY
        let centerX = tx * anchorWidth + anchorCenterX
        
        return CGRect(x: centerX - width/2,
                      y: centerY - height/2,
                      width: width, height: height)
    }
    
    private func filterNonInterectionAndFlat(from predictionsArray: [[DetectedObjectPrediction]]) -> [DetectedObjectPrediction] {
        
        var results: [DetectedObjectPrediction] = []
        for predictions in predictionsArray {
            results.append(contentsOf: filterNonInterection(from: predictions))
        }
        
        return results.sorted(by: { return $0.confidence > $1.confidence })
    }
    
    private func filterNonInterection(from predictions: [DetectedObjectPrediction]) -> [DetectedObjectPrediction] {
        let sortedPredictions = predictions.sorted(by: { return $0.confidence > $1.confidence })
        var results: [DetectedObjectPrediction] = []
        
        for prediction in sortedPredictions {
            
            var shouldSelect = true
            for result in results {
                if CGRect.IOU(prediction.rect, result.rect) > Hyperparameter.IOUThreshold {
                    shouldSelect = false
                    break
                }
            }
            
            if shouldSelect {
                results.append(prediction)
            }
        }
        
        return results
    }
}

extension CGRect {
    /**
     Computes intersection-over-union overlap between two bounding boxes.
     */
    public static func IOU(_ a: CGRect, _ b: CGRect) -> Float {
        let areaA = a.width * a.height
        if areaA <= 0 { return 0 }
        
        let areaB = b.width * b.height
        if areaB <= 0 { return 0 }
        
        let intersectionMinX = max(a.minX, b.minX)
        let intersectionMinY = max(a.minY, b.minY)
        let intersectionMaxX = min(a.maxX, b.maxX)
        let intersectionMaxY = min(a.maxY, b.maxY)
        let intersectionArea = max(intersectionMaxY - intersectionMinY, 0) *
            max(intersectionMaxX - intersectionMinX, 0)
        return Float(intersectionArea / (areaA + areaB - intersectionArea))
    }
    
    func toString(digit: Int) -> String {
        let xStr = String(format: "%.\(digit)f", origin.x)
        let yStr = String(format: "%.\(digit)f", origin.y)
        let wStr = String(format: "%.\(digit)f", width)
        let hStr = String(format: "%.\(digit)f", height)
        return "(\(xStr), \(yStr), \(wStr), \(hStr))"
    }
    
    func scale(to scale: CGFloat) -> CGRect {
        return CGRect(x: origin.x * scale, y: origin.y * scale, width: width * scale, height: height * scale)
    }
    
    func scale(to scale: CGSize) -> CGRect {
        return CGRect(x: origin.x * scale.width,
                      y: origin.y * scale.height,
                      width: width * scale.width,
                      height: height * scale.height)
    }
}
