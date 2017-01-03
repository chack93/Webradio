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
    
    // MARK: - Properties
    var stationListManager = StationListManager.init()
    dynamic var focusedStationItem: StationListItem? {
        didSet {
            // Select default stream in popup button
            if let stationObj = self.focusedStationItem?.stationObject {
                for i in 0..<stationObj.streams.count {
                    if stationObj.streams[i].isDefault {
                        self.focusedStreamIndex = i
                    }
                }
                self.focusedStationIndex = stationObj.index
            }
        }
    }
    var focusedStationIndex = 0 {
        didSet {
            let items = self.stationListCollection.visibleItems()
            for item in items {
                (item as! StationListItem).setBackground()
            }
        }
    }
    dynamic var focusedStreamIndex: Int = 0
    dynamic var volumeLevel: Float = 1.0 {
        didSet {
            streamPlayer.volumeLevel = volumeLevel
        }
    }
    var streamPlayer = StreamPlayer()
    
    // MARK: - ViewController properties/functions
    override var nibName: String? {
        return "MainView"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayout() {
        // Adjust width of list elements, so that only 1 column can be displayed
        let scrollViewWidth = self.stationListScrollView.bounds.width
        if 100 < scrollViewWidth {
            self.stationListCollection.minItemSize.width = scrollViewWidth
        } else {
            self.stationListCollection.minItemSize.width = 100
        }
        self.stationListCollection.minItemSize.height = 48
    }
    
    // MARK: - NSCollectionViewDataSource protocol
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return stationListManager.stations.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "StationListItem", for: indexPath)
        guard let stationListItem = item as? StationListItem else {return item}
        
        stationListItem.stationObject = self.stationListManager.stations[indexPath.item]
        stationListItem.clickCallback = self.navigateStationList
        stationListItem.parentVC = self
        if stationListItem.stationObject!.index == self.focusedStationIndex {
            self.focusedStationItem = stationListItem
        }
        return item
    }
    
    // MARK: - Station list navigation
    func navigateStationList(_ event: NSEvent, selectedItem: StationListItem) {
        switch (event.type) {
        case .leftMouseUp:
            self.focusedStationItem = selectedItem
            guard let stationObj = self.focusedStationItem?.stationObject else {
                Debug.log(level: .Error, file: self.classDescription.className, msg: "Focused station item object missing")
                return
            }
            self.streamPlayer.station = stationObj
            if event.clickCount > 1 {
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
            guard let stationObj = self.focusedStationItem?.stationObject else {
                self.streamPlayer.isPlaying = false
                Debug.log(level: .Error, file: self.classDescription.className, msg: "Focused station item or containing object missing")
                return
            }
            self.streamPlayer.station = stationObj
            self.streamPlayer.play()
        }
    }
    
    @IBAction func changeDefaultStream(_ sender: NSPopUpButtonCell) {
        if let streams = self.focusedStationItem?.stationObject?.streams {
            for i in 0..<streams.count {
                if i == self.focusedStreamIndex {
                    streams[i].isDefault = true
                } else {
                    streams[i].isDefault = false
                }
            }
        }
    }
    @IBAction func addStation(_ sender: NSButton) {
        let newStation = Station.init(title: "New Station", genre: "Genre", image: nil, streams: [], text: nil, favorite: nil, scheduleItems: nil)
        self.stationListManager.stations.append(newStation)
        self.stationListManager.syncStationIndexes()
        self.focusedStationIndex = self.stationListManager.stations.count - 1
        self.stationListCollection.reloadData()
    }
    @IBAction func removeStation(_ sender: NSButton) {
        guard let focusedStation = self.focusedStationItem?.stationObject else {
            return
        }
        guard let idx = self.stationListManager.stations.index(of: focusedStation) else {
            return
        }
        self.stationListManager.stations.remove(at: idx)
        self.stationListManager.syncStationIndexes()
        self.stationListCollection.reloadData()
    }
}
