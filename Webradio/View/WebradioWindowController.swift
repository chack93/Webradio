//
//  WebradioWindowController.swift
//  Webradio
//
//  Created by Christian Hackl on 10/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Cocoa

class WebradioWindowController: NSWindowController {

    override var windowNibName: String? {
        return "WebradioWindowController"
    }
    
    @IBOutlet var mainView: NSView?
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
}
