//
//  Graphics.swift
//  MyCalculator1
//
//  Created by Admin on 03.11.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class GraphicsView: UIView {
    @IBInspectable
    var color: UIColor = UIColor.black
    
    @IBInspectable
    var lineWidth: CGFloat = 0.5
    
    var parabola: [CGPoint] {
        var pointsArray = [CGPoint]()
        for i in 0 ..< 10 {
            pointsArray.append(CGPoint(x: CGFloat(i), y: CGFloat(pow(Double(i), 2.0))))
        }
        return pointsArray
        
    }
    
    var coordinateCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    func pathForParabola() -> UIBezierPath {
        let graphic = UIBezierPath()
        graphic.move(to: coordinateCenter)
        for i in 0 ..< parabola.count {
            graphic.addCurve(to: parabola[i], controlPoint1: parabola[i-1] , controlPoint2: parabola[i])
        }
        graphic.lineWidth = lineWidth
        return graphic
        
    }
    
    
    override func draw(_ rect: CGRect) {
        color.set()
        pathForParabola().stroke()
    }
    
    
    
    
    
    
    
    
    
}
