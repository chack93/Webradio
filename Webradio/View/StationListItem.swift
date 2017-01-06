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
    dynamic var stationObject: Station?
    var clickCallback = {(_: NSEvent, _: Int) -> Void in}
    private var KVOContext = 0
    weak var parentVC: MainViewController? {
        didSet {
            self.parentVC!.addObserver(self,
                                       forKeyPath: "focusedStationIndex",
                                       options: .new,
                                       context: &self.KVOContext)
        }
    }
    
    override var nibName: String? {
        return "StationListItem"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let focusIdx = self.parentVC?.focusedStationIndex {
            self.setBackground(focusedStation: focusIdx)
        } else {
            self.setBackground(focusedStation: -1)
        }
    }
    
    deinit {
        self.parentVC!.removeObserver(self,
                                      forKeyPath: "focusedStationIndex",
                                      context: &self.KVOContext)
    }
    
    // MARK: - methods
    override func mouseUp(with event: NSEvent) {
        if let index = self.stationObject?.index {
            self.clickCallback(event, index)
        } else {
            self.clickCallback(event, -1)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if context != &KVOContext {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        if keyPath == "focusedStationIndex" {
            guard let newValue = change?[.newKey] as? Int else {
                return
            }
            self.setBackground(focusedStation: newValue)
        }
    }
    
    func setBackground(focusedStation: Int) {
        let stationObj = self.stationObject
        if stationObj != nil && stationObj!.index == focusedStation {
            self.gradientBackground.start = NSColor.selectedControlColor
            self.gradientBackground.end = NSColor.init(calibratedWhite: 0.93, alpha: 1.0)
        }
        else {
            if stationObj != nil && stationObj!.favorite {
                self.gradientBackground.start = NSColor.init(calibratedRed: 219/255, green: 201/255, blue: 96/255, alpha: 1.0)
                self.gradientBackground.end = NSColor.init(calibratedRed: 255/238, green: 255/231, blue: 255/192, alpha: 1.0)
            } else {
                self.gradientBackground.start = NSColor.init(calibratedWhite: 0.86, alpha: 1.0)
                self.gradientBackground.end = NSColor.init(calibratedWhite: 0.93, alpha: 1.0)
            }
        }
        self.gradientBackground.needsDisplay = true
    }
}
