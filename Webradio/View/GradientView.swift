//
//  GradientView.swift
//  Webradio
//
//  Created by Christian Hackl on 18/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Cocoa

@IBDesignable
class GradientView: NSView {
    
    public var start: NSColor = NSColor.init(calibratedWhite: 0.0, alpha: 0.0)
    public var end: NSColor = NSColor.init(calibratedWhite: 0.0, alpha: 0.0)
    public var angle: CGFloat = 0.0
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let gradient = NSGradient.init(starting: self.start, ending: self.end)
        gradient?.draw(in: self.bounds, angle: self.angle)
    }
    
}
