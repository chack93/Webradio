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

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func editStreams(sender: NSButton) {
        let streamsEditWC = StreamDetailWindowController()
        if let viewController = self.mainViewController, let streams = viewController.focusedStationItem?.stationObject?.streams {
            streamsEditWC.streamItems = streams
            self.window!.beginSheet(streamsEditWC.window!, completionHandler: { response in
                if response == NSModalResponseOK {
                    let editedStreams = self.streamsEditWC!.streamItems
                    viewController.focusedStationItem!.stationObject!.streams = editedStreams
                    viewController.updateView()
                }
                self.window!.endSheet(self.streamsEditWC!.window!)
                
                self.streamsEditWC = nil
            })
            self.streamsEditWC = streamsEditWC
        }
    }
}
