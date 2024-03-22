//
//  DrawingView.swift
//  TriangleOfLife
//
//  Created by Yunus Emre Berdibek on 21.03.2024.
//

import UIKit

final class DrawingView: UIView {
    var heatmap: [[Double]]? = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.clear(rect)
            
            guard let heatmap = heatmap else { return }
            
            let size = bounds.size
            let heatmap_w = heatmap.count
            let heatmap_h = heatmap.first?.count ?? 0
            let w = size.width / CGFloat(heatmap_w)
            let h = size.height / CGFloat(heatmap_h)
            
            for j in 0..<heatmap_h {
                for i in 0..<heatmap_w {
                    let value = heatmap[i][j]
                    var alpha: CGFloat = .init(value)
                    if alpha > 1 {
                        alpha = 1
                    } else if alpha < 0 {
                        alpha = 0
                    }
                    
                    let rect: CGRect = .init(x: CGFloat(i) * w, y: CGFloat(j) * h, width: w, height: h)
                    
                    // gray
                    let color: UIColor = .init(white: 1 - alpha, alpha: 1)
                    
                    let bpath: UIBezierPath = .init(rect: rect)
                    
                    color.set()
                    bpath.fill()
                }
            }
        }
    }
}
