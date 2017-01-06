//
//  MainViewController.swift
//  Webradio
//
//  Created by Christian Hackl on 24/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSCollectionViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var stationListCollection: NSCollectionView!
    @IBOutlet weak var stationListScrollView: NSScrollView!
    @IBOutlet weak var streamSelectArray: NSArrayController!
    @IBOutlet weak var stationDetailView: NSView!
    
    // MARK: - Properties
    var stationListManager = StationListManager.init()
    dynamic var focusedStationIndex: Int = -1 {
        didSet {
            self.focusedStation = self.stationListManager.stations[self.focusedStationIndex]
        }
    }
    dynamic var focusedStation: Station? {
        didSet {
            if let stationObj = self.focusedStation {
                for i in 0..<stationObj.streams.count {
                    if stationObj.streams[i].isDefault {
                        self.focusedStreamIndex = i
                    }
                }
            }
        }
    }
    dynamic var focusedStreamIndex: Int = -1
    dynamic var volumeLevel: Float = 1.0 {
        didSet {
            streamPlayer.volumeLevel = volumeLevel
        }
    }
    let streamPlayer = StreamPlayer()
    
    // MARK: - ViewController properties/functions
    override var nibName: String? {
        return "MainView"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stationListCollection.maxNumberOfColumns = 1
        self.focusedStationIndex = 0
    }
    
    override func viewWillLayout() {
        let bounds = self.view.bounds
        if bounds.width < 480 {
            self.stationDetailView.isHidden = true
        } else {
            self.stationDetailView.isHidden = false
        }
        self.stationDetailView.needsDisplay = true
    }
    
    // MARK: - NSCollectionViewDataSource protocol
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return stationListManager.stations.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "StationListItem", for: indexPath)
        guard let stationListItem = item as? StationListItem else {return item}
        
        stationListItem.parentVC = self
        stationListItem.stationObject = self.stationListManager.stations[indexPath.item]
        stationListItem.clickCallback = self.navigateStationList
        stationListItem.setBackground(focusedStation: self.focusedStationIndex)
        return item
    }
    
    // MARK: - Station list navigation
    func navigateStationList(_ event: NSEvent, selectedIndex: Int) {
        switch (event.type) {
        case .leftMouseUp:
            self.focusedStationIndex = selectedIndex
            if event.clickCount > 1 {
                self.streamPlayer.station = self.stationListManager.stations[selectedIndex]
                self.streamPlayer.play()
            }
            break
        default:
            break
        }
    }
    
    // MARK: - IBActions
    @IBAction func playPause(_ sender: NSButton) {
        if !(sender.objectValue as! Bool) {
            self.streamPlayer.pause()
        } else {
            let focusedStation = self.stationListManager.stations[self.focusedStationIndex]
            self.streamPlayer.station = focusedStation
            self.streamPlayer.play()
        }
    }
    @IBAction func changeDefaultStream(_ sender: NSPopUpButtonCell) {
        let streams = self.stationListManager.stations[self.focusedStationIndex].streams
        for i in 0..<streams.count {
            if i == self.focusedStreamIndex {
                streams[i].isDefault = true
            } else {
                streams[i].isDefault = false
            }
            
        }
    }
    @IBAction func addStation(_ sender: NSButton) {
        let newStation = Station.init(title: "New Station", genre: "Genre", image: nil, streams: [], text: nil, favorite: nil, scheduleItems: nil)
        self.stationListManager.stations.append(newStation)
        self.stationListManager.syncStationIndexes()
        self.stationListCollection.reloadData()
        self.focusedStationIndex = self.stationListManager.stations.count - 1
    }
    @IBAction func removeStation(_ sender: NSButton) {
        if self.focusedStationIndex < 0 {
            return
        }
        self.stationListManager.stations.remove(at: self.focusedStationIndex)
        self.stationListManager.syncStationIndexes()
        self.stationListCollection.reloadData()
        self.focusedStationIndex = self.focusedStationIndex - 1
    }
}
