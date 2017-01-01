//
//  MainViewController.swift
//  Webradio
//
//  Created by Christian Hackl on 24/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Cocoa
import AVFoundation

class MainViewController: NSViewController, NSCollectionViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var stationListCollection: NSCollectionView!
    @IBOutlet weak var stationListScrollView: NSScrollView!
    @IBOutlet weak var streamSelectArray: NSArrayController!
    
    @IBOutlet weak var stationDetailView: NSView!
    // MARK: - Properties
    var stationList = StationList.init()
    dynamic var focusedStationItem: StationListItem? {
        didSet {
            self.updateView()
        }
    }
    dynamic var focusedStreamIndex: Int = 0
    dynamic var playingStation: Station?
    var focusFirstStationItem = true
    var player: AVPlayer?
    
    // MARK: - ViewController functions
    override var nibName: String? {
        return "MainView"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let streamItem = StreamItem.init(stream: URL.init(string: "http://stream.srg-ssr.ch/m/rsj/aacp_96")!, title: "AAC")
        let streamItem2 = StreamItem.init(stream: URL.init(string: "http://stream.srg-ssr.ch/m/rsj/mp3_128")!, title: "MP3")
        let streamItem3 = StreamItem.init(stream: URL.init(string: "http://example.org")!, title: "example")
        let testStation = Station.init(title: "Hello", genre: nil, image: nil, streams: [streamItem, streamItem2], text: "Description", favorite: true, scheduleItems: nil)
        let testStation2 = Station.init(title: "xxx", genre: "yyy", image: NSImage.init(named: "PauseIcon"), streams: [streamItem3], text: "Description2", favorite: false, scheduleItems: nil)
        self.stationList.stations.append(testStation)
        self.stationList.stations.append(testStation2)
        self.stationList.stations.append(testStation2)
        self.stationList.stations.append(testStation2)
        self.stationList.stations.append(testStation2)
        self.stationList.stations.append(testStation2)
        self.stationList.stations.append(testStation2)
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
    
    func updateView() {
        if let stationObj = self.focusedStationItem?.stationObject {
            for i in 0..<stationObj.streams.count {
                if stationObj.streams[i].isDefault {
                    self.focusedStreamIndex = i
                }
            }
        }
    }
    
    // MARK: - NSCollectionViewDataSource protocol
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return stationList.stations.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "StationListItem", for: indexPath)
        guard let stationListItem = item as? StationListItem else {return item}
        
        stationListItem.stationObject = self.stationList.stations[indexPath.item]
        stationListItem.clickCallback = self.navigateStationList
        
        // focus first item on startup
        if self.focusFirstStationItem && indexPath.item == 0 {
            stationListItem.isFocused = true
            self.focusFirstStationItem = false
            focusedStationItem = stationListItem
        }
        
        return item
    }
    
    // MARK: - Navigation function
    func navigateStationList(_ event: NSEvent, selectedItem: StationListItem) {
        switch (event.type) {
        case .leftMouseUp:
            if let lastFocusedItem = self.focusedStationItem {
                lastFocusedItem.isFocused = false
            }
            selectedItem.isFocused = true
            self.focusedStationItem = selectedItem
            break
        default:
            break
        }
    }
    
    // MARK: - IBActions
    @IBAction func playPause(_ sender: NSButton) {
        if self.player == nil {
            self.player = AVPlayer.init()
        }
        if !(sender.objectValue as! Bool) {
            self.player!.pause()
        } else {
            if let streams = self.focusedStationItem?.stationObject?.streams {
                for stream in streams {
                    if stream.isDefault {
                        if let streamURL = stream.stream {
                            let playerItem = AVPlayerItem.init(url: streamURL)
                            self.player?.replaceCurrentItem(with: playerItem)
                        }
                        break
                    }
                }
            }
            self.player!.play()
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
}
