//
//  MainViewController.swift
//  Webradio
//
//  Created by Christian Hackl on 24/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Cocoa

class MainView: NSView {
    
    var drawBorder = false {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func awakeFromNib() {
        let draggedTypes = Array.init(arrayLiteral: NSFilenamesPboardType)
        self.register(forDraggedTypes: draggedTypes)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if self.drawBorder {
            NSBezierPath.setDefaultLineWidth(5.0)
            NSColor.keyboardFocusIndicatorColor.set()
            NSBezierPath.stroke(dirtyRect)
        }
    }
    
    // MARK: - Drag & Drop
    
    var dropCallback: (([URL]) -> Void)?
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pasteboard = sender.draggingPasteboard()
        guard let paths = pasteboard.propertyList(forType: NSFilenamesPboardType) as? [String] else {
            return []
        }
        for path in paths {
            guard let ext = path.components(separatedBy: ".").last else {
                continue
            }
            if StationListManager.availableImporter.contains(ext.lowercased()) {
                self.drawBorder = true
                return NSDragOperation.every
            }
        }
        self.drawBorder = false
        return []
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.drawBorder = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        self.drawBorder = false
        return true
    }
    
    override func concludeDragOperation(_ sender: NSDraggingInfo?) {
        self.drawBorder = false
        guard var paths = sender?.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? [String] else {
            return
        }
        var urls = [URL]()
        for i in 0..<paths.count {
            //paths[i] = "file://" + paths[i]
            urls.append(URL.init(fileURLWithPath: paths[i]))
        }
        if paths.count > 0 && self.dropCallback != nil {
            self.dropCallback!(urls)
        }
    }
}

class MainViewController: NSViewController, NSCollectionViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var stationListCollection: NSCollectionView!
    @IBOutlet weak var stationListScrollView: NSScrollView!
    @IBOutlet weak var streamSelectArray: NSArrayController!
    @IBOutlet weak var stationDetailView: NSView!
    @IBOutlet weak var mainWindow: NSWindow!
    
    // MARK: - Properties
    var stationListManager = StationListManager.init()
    dynamic var focusedStationIndex: Int = -1 {
        didSet {
            if self.focusedStationIndex < 0 ||
                self.focusedStationIndex > self.stationListManager.stations.count - 1 {
                self.focusedStation = nil
            } else {
                self.focusedStation = self.stationListManager.stations[self.focusedStationIndex]
            }
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
        guard let mainView = self.view as? MainView else { return }
        mainView.dropCallback = self.addStationsFrom
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
    
    /** Creates & appends stations/streams from given filepaths
     - parameters:
     - filePaths: URLs to read from
    */
    func addStationsFrom(_ filePaths: [URL]) {
        var stations = [Station]()
        for path in filePaths {
            if StationListManager.availableImporter.contains(path.pathExtension) {
                guard let stationsInFile = StationListManager.stationFrom(file: path) else { continue }
                stations.append(contentsOf: stationsInFile)
            }
        }
        if stations.count > 0 {
            self.stationListManager.stations.append(contentsOf: stations)
            self.stationListCollection.reloadData()
            self.focusedStationIndex = self.stationListManager.stations.count - 1
        }
    }
    
    /** Creates playlist of all saved stations & saves it given path. File extension of path defines playlist type
     - parameters:
     - path: Path where the created playlist will be saved
     */
    func exportPlaylist(_ path: URL) {
        let stations = self.stationListManager.stations
        if stations.count < 1 { return }
        
        let exportString = StationListManager.createPlaylistFrom(stations, ofType: "m3u")
        do {
            try exportString.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            Debug.log(level: .Error, file: "MainViewController", msg: "Unable to write playlist to file")
            self.mainWindow.presentError(error)
        }
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
        self.stationListCollection.reloadData()
        self.focusedStationIndex = self.stationListManager.stations.count - 1
    }
    @IBAction func removeStation(_ sender: NSButton) {
        if self.focusedStationIndex < 0 {
            return
        }
        self.stationListManager.stations.remove(at: self.focusedStationIndex)
        self.stationListCollection.reloadData()
        self.focusedStationIndex = self.focusedStationIndex - 1
    }
}
