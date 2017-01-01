//
//  MainWindowController.swift
//  Webradio
//
//  Created by Christian Hackl on 10/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    @IBOutlet var mainViewController: MainViewController?
    
    var streamsEditWC: StreamDetailWindowController?
    
    override var windowNibName: String? {
        return "MainWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    @IBAction func editStreams(sender: NSButton) {
        let streamsEditWC = StreamDetailWindowController()
        if let viewController = self.mainViewController, let streams = viewController.focusedStationItem?.stationObject?.streams {
            streamsEditWC.streamItems = streams
            self.window!.beginSheet(streamsEditWC.window!, completionHandler: { response in
                if response == NSModalResponseOK {
                    let editedStreams = self.streamsEditWC!.streamItems
                    viewController.focusedStationItem!.stationObject!.streams = editedStreams
                    // Select default stream in popup button
                    if let stationObj = viewController.focusedStationItem?.stationObject {
                        for i in 0..<stationObj.streams.count {
                            if stationObj.streams[i].isDefault {
                                viewController.focusedStreamIndex = i
                            }
                        }
                    } else {
                        Debug.log(level: .Error, file: self.classDescription.className, msg: "focused station item or stationObject missing")
                    }
                }
                self.window!.endSheet(self.streamsEditWC!.window!)
                
                self.streamsEditWC = nil
            })
            self.streamsEditWC = streamsEditWC
        }
    }
}
