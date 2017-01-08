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

    var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let mainWindowController = MainWindowController()
        mainWindowController.showWindow(self)
        self.mainWindowController = mainWindowController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        self.mainWindowController!.prepareClosing()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if (flag) {
            return false
        } else {
            let window = NSApplication.shared().windows.first as NSWindow?
            if (window != nil) {
                window?.makeKeyAndOrderFront(self)
            }
            return true
        }
    }
    
    @IBAction func saveList(_ sender: NSMenuItem) {
        guard let mainVC = self.mainWindowController?.mainViewController else { return }
        mainVC.stationListManager.saveStationList()
    }
    
    @IBAction func importStation(_ sender: NSMenuItem) {
        guard let mainVC = self.mainWindowController?.mainViewController else { return }
        let openPanel = NSOpenPanel()
        let allowedTypes = StationListManager.availableImporter
        
        openPanel.prompt = "Choose"
        openPanel.worksWhenModal = true
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.title = "Choose Playlist file"
        openPanel.allowedFileTypes = allowedTypes
        
        if openPanel.runModal() == NSFileHandlingPanelOKButton {
            mainVC.addStationsFrom(openPanel.urls)
        }
    }
}

