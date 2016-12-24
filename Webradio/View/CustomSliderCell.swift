//
//  CustomSlider.swift
//  Webradio
//
//  Created by Christian Hackl on 18/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Cocoa

@IBDesignable
class CustomSliderCell: NSSliderCell {
    var leftColor = NSColor.init(calibratedWhite: 0.0, alpha: 0.0)
    var rightColor = NSColor.init(calibratedWhite: 0.0, alpha: 0.8)
    var borderRadius = 2.0 as CGFloat
    var barHeight = 4.0 as CGFloat
    
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        var barRect = rect
        barRect.size.height = self.barHeight
        barRect.origin.y = barRect.origin.y + 0.5
        let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
        let finalWidth = CGFloat(value * (self.controlView!.frame.size.width - 8))
        var leftRect = barRect
        leftRect.size.width = finalWidth
        let background = NSBezierPath(roundedRect: barRect, xRadius: self.borderRadius, yRadius: self.borderRadius)
        self.rightColor.set()
        background.fill()
        let active = NSBezierPath(roundedRect: leftRect, xRadius: self.borderRadius, yRadius: self.self.borderRadius)
        self.leftColor.set()
        active.fill()
    }
}
