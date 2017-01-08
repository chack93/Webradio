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
        guard let mainWindow = self.mainWindowController?.window else { return }
        let openPanel = NSOpenPanel()
        let allowedTypes = StationListManager.availableImporter
        
        openPanel.prompt = "Choose"
        openPanel.worksWhenModal = true
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.title = "Choose Playlist file"
        openPanel.allowedFileTypes = allowedTypes
        
        openPanel.beginSheetModal(for: mainWindow, completionHandler: {(response: Int) -> Void in
            if response == NSModalResponseOK {
                mainVC.addStationsFrom(openPanel.urls)
            }
        })
    }
    @IBAction func exportStation(_ sender: NSMenuItem) {
        guard let mainVC = self.mainWindowController?.mainViewController else { return }
        guard let mainWindow = self.mainWindowController?.window else { return }
        let savePanel = NSSavePanel()
        let allowedTypes = StationListManager.availableImporter
        
        savePanel.title = "Save"
        savePanel.prompt = "Save"
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        savePanel.allowedFileTypes = allowedTypes
        savePanel.nameFieldStringValue = "Untitled." + allowedTypes.last!
        savePanel.allowsOtherFileTypes = false
        savePanel.treatsFilePackagesAsDirectories = false
        
        savePanel.beginSheetModal(for: mainWindow, completionHandler: {(response: Int) -> Void in
            if response == NSModalResponseOK {
                if savePanel.url != nil {
                    mainVC.exportPlaylist(savePanel.url!)
                }
            }
        })
    }
}

