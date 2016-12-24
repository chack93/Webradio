//
//  WebradioController.swift
//  Webradio
//
//  Created by Christian Hackl on 24/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSCollectionViewDataSource {
    // MARK: - outlets
    @IBOutlet weak var stationListCollection: NSCollectionView!
    
    // MARK: - properties
    var stationList = StationList.init()
    
    // MARK: - NSCollectionViewDataSource protocol
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 2 // Favorites & all stations
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return stationList.favoriteStations.count
        case 1:
            return stationList.stations.count
        default:
            return 0
        }
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "StationListItem", for: indexPath)
        guard let stationListItem = item as? StationListItem else {return item}
        
        switch (indexPath.section) {
        case 0:
            stationListItem.stationTitle = stationList.favoriteStations[indexPath.item].title
            stationListItem.stationGenre = stationList.favoriteStations[indexPath.item].genre
            stationListItem.stationImage = stationList.favoriteStations[indexPath.item].image
            stationListItem.isFavorite = true
        case 1:
            stationListItem.stationTitle = stationList.stations[indexPath.item].title
            stationListItem.stationGenre = stationList.stations[indexPath.item].genre
            stationListItem.stationImage = stationList.stations[indexPath.item].image
            stationListItem.isFavorite = false
        default:
            break
        }
        return item
    }
    
    override var nibName: String? {
        return "MainView"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let testStation = Station.init(title: "Hello", genre: "World", image: nil, streams: [URL.init(string: "http://xyz.com")!], text: "Description", favorite: true, scheduleItems: nil)
        self.stationList.stations.append(testStation)
        self.view.needsDisplay = true
    }
    
}
