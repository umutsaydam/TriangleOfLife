//
//  Rotatable.swift
//  TriangleOfLife
//
//  Created by Yunus Emre Berdibek on 21.03.2024.
//

import UIKit

protocol Rotatable
{
    var transform: CGAffineTransform { get set }
    
    mutating func rotate(degrees: CGFloat, animated: Bool)
    mutating func rotate(radians: CGFloat, animated: Bool)
    
    var rotation: (radians: CGFloat, degrees: CGFloat) { get }
}

extension UIView: Rotatable
{}

extension Rotatable
{
    mutating func rotate(degrees: CGFloat, animated: Bool = false)
    {
        rotate(radians: degreesToRadians(value: degrees), animated: animated)
    }
    
    mutating func rotate(radians: CGFloat, animated: Bool = false)
    {
        transform = CGAffineTransform(rotationAngle: radians)
    }
    
    var rotation: (radians: CGFloat, degrees: CGFloat)
    {
        let radians = CGFloat(atan2f(Float(transform.b), Float(transform.a)))
        
        return (radians, radiansToDegrees(value: radians))
    }
    
    func degreesToRadians(value: CGFloat) -> CGFloat
    {
        return CGFloat(Double.pi) * value / 180.0
    }
    
    func radiansToDegrees(value: CGFloat) -> CGFloat
    {
        return value * 180 / CGFloat(Double.pi)
    }
}
