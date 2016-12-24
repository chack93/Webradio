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

    var stationImage = NSImage.init(named: "DefaultStationIcon")
    var stationTitle = ""
    var stationGenre = ""
    var isFavorite = false
    
    @IBOutlet weak var gradientBackground: GradientView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isFavorite {
            gradientBackground.start = NSColor.init(calibratedRed: 255/219, green: 255/201, blue: 255/96, alpha: 1.0)
            gradientBackground.end = NSColor.init(calibratedRed: 255/238, green: 255/231, blue: 255/192, alpha: 1.0)
        } else {
            gradientBackground.start = NSColor.init(calibratedWhite: 0.86, alpha: 1.0)
            gradientBackground.end = NSColor.init(calibratedWhite: 0.93, alpha: 1.0)
        }
    }
    
}
