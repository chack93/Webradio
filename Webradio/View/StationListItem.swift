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
    var clickCallback = {(_: NSEvent, _: StationListItem) -> Void in}
    weak var parentVC: MainViewController?
    
    override var nibName: String? {
        return "StationListItem"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackground()
    }
    
    // MARK: - methods
    override func mouseUp(with event: NSEvent) {
        self.clickCallback(event, self)
        self.setBackground()
    }
    
    func setBackground() {
        if let me = stationObject {
            var isFocused = false
            if let focusIdx = self.parentVC?.focusedStationIndex,
                let index = self.stationObject?.index {
                if index == focusIdx {
                    isFocused = true
                }
            }
            if me.favorite {
                gradientBackground.start = NSColor.init(calibratedRed: 219/255, green: 201/255, blue: 96/255, alpha: 1.0)
                gradientBackground.end = NSColor.init(calibratedRed: 255/238, green: 255/231, blue: 255/192, alpha: 1.0)
                
                if isFocused {
                    gradientBackground.end = NSColor.selectedMenuItemColor.blended(withFraction: 0.2, of: NSColor.white)!
                }
                
            } else {
                if isFocused {
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
