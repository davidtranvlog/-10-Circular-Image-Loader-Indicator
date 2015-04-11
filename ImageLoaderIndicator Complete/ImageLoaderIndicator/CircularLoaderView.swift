//
//  CircularLoaderView.swift
//  ImageLoaderIndicator
//
//  Created by Duc Tran on 4/11/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit

class CircularLoaderView: UIView {
    
    // represents the circular path
    let circlePathLayer = CAShapeLayer()
    // radius of the circular path
    let circleRadius: CGFloat = 20.0
    
    var progress: CGFloat
    {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if newValue > 1 {
                circlePathLayer.strokeEnd = 1
            } else if newValue < 0 {
                // no part of the shape layer was drawn
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }

    // Initialization to configure the shape layer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(code aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure() {
        // initialize progress on the first run
        progress = 0
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 2
        
        // clear fill color
        circlePathLayer.fillColor = UIColor.clearColor().CGColor
        // red stroke color
        circlePathLayer.strokeColor = UIColor.redColor().CGColor
        
        // add the layer as a sublayer of the view's main layer
        layer.addSublayer(circlePathLayer)
        // background color of the main view to be white
        backgroundColor = UIColor.whiteColor()
    }
    
    // returns an instance of CGRect that bounds the indicator's path
    // the bounding rectangle is 2*circleRadius wide and tall, at the 
    // center of the view
    
    func circleFrame() -> CGRect
    {
        // update the circle frame in case the size of the view changes
        var circleFrame = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
        circleFrame.origin.x = CGRectGetMidX(circlePathLayer.bounds) - CGRectGetMidX(circleFrame)
        circleFrame.origin.y = CGRectGetMidY(circlePathLayer.bounds) - CGRectGetMidY(circleFrame)
        return circleFrame
    }
    
    // returns the circule UIBezierPath as bounded by circleFrame
    func circlePath() -> UIBezierPath {
        // circleFrame() returns a square -> ovalInRect: returns a circle
        return UIBezierPath(ovalInRect: circleFrame())
    }
    
    // layers don't have autoresizingMask property, need to update circlePathLayer's frame
    // to respond appropriately to changes in the view's size
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        // call circlePath() to recalculate the path once the frame changes
        circlePathLayer.path = circlePath().CGPath
    }
    
    // Reveal the image
    func reveal()
    {
        // set backgroundColor to clear so the image behind it is not hidden anymore
        backgroundColor = UIColor.clearColor()
        progress = 1
        // remove pending implicit animations for the strokeEnd property
        circlePathLayer.removeAnimationForKey("strokeEnd")
        
        // remove circlePathLayer from its superlayer ...
        circlePathLayer.removeFromSuperlayer()
        // ...assign it to the superView's layer mask so the image is visible through
        // the circular mask "hole"
        superview?.layer.mask = circlePathLayer
        
        // expand the ring both inwards and outwards to reveal the whole image view
        
        // calculate the radius of the circle that can fully circumscribe the image view
        let center = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
        let finalRadius = sqrt((center.x*center.x) + (center.y*center.y))
        let radiusInset = finalRadius - circleRadius
        // calculate the CGRect that will fully bound this circle
        let outerRect = CGRectInset(circleFrame(), -radiusInset, -radiusInset)
        // represents the final shape of the CAShapeLayer mask
        let toPath = UIBezierPath(ovalInRect: outerRect).CGPath
        
        // set the initial values of lineWidth and path to match the current values of the layer
        let fromPath = circlePathLayer.path
        let fromLineWidth = circlePathLayer.lineWidth
        
        // set the lineWidth and path to their final values
        // this prevents them from jumping back to their their original values
        // when the animation completes.
        // wrapping this in a CATransaction with kCATransactionDisableActions set to true 
        // disables the layer's implicit animations
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        circlePathLayer.lineWidth = 2*finalRadius
        circlePathLayer.path = toPath
        CATransaction.commit()
        
        // 2 instances of CABasicAnimation for path and lineWidth
        // lineWidth increases twice as fast as the radius increases
        // so that the circle expand inward as well as outward
        let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineWidthAnimation.fromValue = fromLineWidth
        lineWidthAnimation.toValue = 2*finalRadius
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = fromPath
        pathAnimation.toValue = toPath
        
        // add both animations to CAAnimationGroup
        // add the animation group to the layer to assign self as the delegate
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = 1
        groupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        groupAnimation.animations = [pathAnimation, lineWidthAnimation]
        groupAnimation.delegate = self
        circlePathLayer.addAnimation(groupAnimation, forKey: "strokeWidth")
    }
    
    // fix the remaining hidden portion of the image after loaded
    // removes the mask on the super layer that will remove the circle entirely
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        superview?.layer.mask = nil
    }

}


























