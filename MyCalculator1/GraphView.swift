//
//  CoordinatesView.swift
//  MyCalculator1
//
//  Created by Admin on 04.11.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit

import UIKit

@IBDesignable
class GraphView: UIView {
    
    var yForX: ((_ x: Double) -> Double?)? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var scale: CGFloat = 50.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var lineWidth: CGFloat = 2.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var color: UIColor = UIColor.yellow {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var originRelativeToCenter = CGPoint.zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    fileprivate var graphCenter: CGPoint {
        return convert(center, from: superview)
    }
    
    fileprivate var origin: CGPoint {
        get {
            var origin = originRelativeToCenter
            origin.x += graphCenter.x
            origin.y += graphCenter.y
            return origin
        } set {
            var origin = newValue
            origin.x -= graphCenter.x
            origin.y -= graphCenter.y
            originRelativeToCenter = origin
        }
    }
    
    fileprivate var axesDrawer = AxesDrawer(color: UIColor.white)
    
    fileprivate var lightCurve: Bool = false
    
    override func draw(_ rect: CGRect) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
        if !lightCurve {
            drawCurveInRect(bounds, origin: origin, scale: scale)
        }
    }
    
    func drawCurveInRect(_ bounds: CGRect, origin: CGPoint, scale: CGFloat) {
        UIColor(red: 0.956863, green: 0.890937, blue: 0.353418, alpha: 1.0).set()
        var xGraph: CGFloat = 0.0
        var yGraph: CGFloat = 0.0
        
        var x: Double {
            return Double((xGraph - origin.x)/scale)
        }
        
        var oldPoint = OldPoint(yGraph: 0.0, normal: false)
        var disContinuity: Bool {
            return abs(yGraph - oldPoint.yGraph) > max(bounds.width, bounds.height) * 1.5
        }
        
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        for i in 0...Int(self.bounds.size.width * self.contentScaleFactor){
            
            xGraph = CGFloat(i) / self.contentScaleFactor
            
            guard let y = (self.yForX)?(x), y.isFinite
                else {
                    oldPoint.normal = false;  continue
            }
            
            yGraph = origin.y - CGFloat(y) * scale
            
            if !oldPoint.normal{
                path.move(to: CGPoint(x: xGraph, y: yGraph))
            } else {
                guard !disContinuity
                    else {
                        oldPoint =  OldPoint ( yGraph: yGraph, normal: false)
                        continue
                }
                path.addLine(to: CGPoint(x: xGraph, y: yGraph))
            }
            oldPoint =  OldPoint (yGraph: yGraph, normal: true)
            
        }
        path.stroke()
        
    }
    
    
    fileprivate struct OldPoint {
        var yGraph: CGFloat
        var normal: Bool
    }
    
    fileprivate var snapshot: UIView?
    
    func scale(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began: snapshot = self.snapshotView(afterScreenUpdates: false)
            snapshot!.alpha = 0.8
            self.addSubview(snapshot!)
        case .changed:
            let touch = gesture.location(in: self)
            snapshot!.frame.size.height *= gesture.scale
            snapshot!.frame.size.width *= gesture.scale
            snapshot!.frame.origin.x = snapshot!.frame.origin.x * gesture.scale + (1 - gesture.scale) * touch.x
            snapshot!.frame.origin.y = snapshot!.frame.origin.y * gesture.scale + (1 - gesture.scale) * touch.y
            gesture.scale = 1.0
        case .ended:
            let changedScale = snapshot!.frame.height / self.frame.height
            scale *= changedScale
            origin.x = origin.x * changedScale + snapshot!.frame.origin.x
            origin.y = origin.y * changedScale + snapshot!.frame.origin.y
            snapshot!.removeFromSuperview()
            snapshot = nil
            setNeedsDisplay()
        default: break
        }
    }
    
    func originMove(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .ended: fallthrough
        case .changed:
            let translation = gesture.translation(in: self)
            if translation != CGPoint.zero {
                origin.x += translation.x
                origin.y += translation.y
                gesture.setTranslation(CGPoint.zero, in: self)
            }
        default: break
        }
    }
    
    func origin(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            origin = gesture.location(in: self)
        }
    }
    
    
   
}
