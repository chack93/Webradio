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
    
    func prepareClosing() {
        self.mainViewController!.stationListManager.saveStationList()
    }
    
    @IBAction func editStreams(sender: NSButton) {
        let streamsEditWC = StreamDetailWindowController()
        guard let viewController = self.mainViewController else {
            return
        }
        let stationFI = viewController.focusedStationIndex
        let focusedStation = viewController.stationListManager.stations[stationFI]
        
        // open sheet
        streamsEditWC.streamItems = focusedStation.streams
        self.window!.beginSheet(streamsEditWC.window!, completionHandler: { response in
            
            if response == NSModalResponseOK {
                let editedStreams = self.streamsEditWC!.streamItems
                focusedStation.streams = editedStreams
                // Select default stream in popup button
                for i in 0..<focusedStation.streams.count {
                    if focusedStation.streams[i].isDefault {
                        viewController.focusedStreamIndex = i
                    }
                }
            }
            self.window!.endSheet(self.streamsEditWC!.window!)
            self.streamsEditWC = nil
            
        })
        self.streamsEditWC = streamsEditWC
        
    }
}
