//
//  UIViewController+Extensions.swift
//  TriangleOfLife
//
//  Created by Yunus Emre Berdibek on 22.03.2024.
//

import CoreML
import UIKit

extension UIViewController {
    func convertTo2DArray(from heatmaps: MLMultiArray) -> ([[Double]], [[Int]]) {
        guard heatmaps.shape.count >= 3 else {
            print("heatmap's shape is invalid. \(heatmaps.shape)")
            return ([], [])
        }
        _ /* keypoint_number */ = heatmaps.shape[0].intValue
        let heatmap_w = heatmaps.shape[1].intValue
        let heatmap_h = heatmaps.shape[2].intValue

        var convertedHeatmap: [[Double]] = Array(repeating: Array(repeating: 0.0, count: heatmap_w), count: heatmap_h)

        var minimumValue = Double.greatestFiniteMagnitude
        var maximumValue: Double = -Double.greatestFiniteMagnitude

        for i in 0..<heatmap_w {
            for j in 0..<heatmap_h {
                let index = i * heatmap_h + j
                let confidence = heatmaps[index].doubleValue
                guard confidence > 0 else { continue }
                convertedHeatmap[j][i] = confidence

                if minimumValue > confidence {
                    minimumValue = confidence
                }
                if maximumValue < confidence {
                    maximumValue = confidence
                }
            }
        }

        let minmaxGap = maximumValue - minimumValue

        for i in 0..<heatmap_w {
            for j in 0..<heatmap_h {
                convertedHeatmap[j][i] = (convertedHeatmap[j][i] - minimumValue) / minmaxGap
            }
        }

        var convertedHeatmapInt: [[Int]] = Array(repeating: Array(repeating: 0, count: heatmap_w), count: heatmap_h)
        for i in 0..<heatmap_w {
            for j in 0..<heatmap_h {
                if convertedHeatmap[j][i] >= 0.5 {
                    convertedHeatmapInt[j][i] = Int(1)
                } else {
                    convertedHeatmapInt[j][i] = Int(0)
                }
            }
        }

        return (convertedHeatmap, convertedHeatmapInt)
    }
}
