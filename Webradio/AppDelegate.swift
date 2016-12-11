//
//  AppDelegate.swift
//  Webradio
//
//  Created by Christian Hackl on 10/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var webradioWindowController: WebradioWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let webradioWindowController = WebradioWindowController()
        webradioWindowController.showWindow(self)
        self.webradioWindowController = webradioWindowController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
}

