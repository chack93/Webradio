//
//  StationListItem.swift
//  Webradio
//
//  Created by Christian Hackl on 18/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Cocoa

@IBDesignable
class StationListItem: NSCollectionViewItem {

    // MARK: - IBOutlets
    @IBOutlet weak var gradientBackground: GradientView!
    
    // MARK: - properties
    dynamic var stationObject: Station? {
        didSet {
            self.setBackground()
        }
    }
    var isFocused = false {
        didSet {
            self.setBackground()
        }
    }
    var clickCallback = {(_: NSEvent, _: StationListItem) -> Void in}
    
    override var nibName: String? {
        return "StationListItem"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - methods
    override func mouseUp(with event: NSEvent) {
        self.clickCallback(event, self)
    }
    
    func setBackground() {
        if let me = stationObject {
            if me.favorite {
                gradientBackground.start = NSColor.init(calibratedRed: 219/255, green: 201/255, blue: 96/255, alpha: 1.0)
                gradientBackground.end = NSColor.init(calibratedRed: 255/238, green: 255/231, blue: 255/192, alpha: 1.0)
                if self.isFocused {
                    gradientBackground.end = NSColor.selectedMenuItemColor.blended(withFraction: 0.2, of: NSColor.white)!
                }
            } else {
                if self.isFocused {
                    gradientBackground.start = NSColor.selectedMenuItemColor
                    gradientBackground.end = NSColor.selectedMenuItemColor.blended(withFraction: 0.2, of: NSColor.white)!
                } else {
                    gradientBackground.start = NSColor.init(calibratedWhite: 0.86, alpha: 1.0)
                    gradientBackground.end = NSColor.init(calibratedWhite: 0.93, alpha: 1.0)
                }
            }
        }
        self.gradientBackground.needsDisplay = true
    }
    
}
