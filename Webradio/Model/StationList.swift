//
//   StationLibrary.swift
//  Webradio
//
//  Created by Christian Hackl on 11/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Foundation
import AppKit

public class StationList {
    private let stationListFileName = "stationList.wrl"
    
    /// List of all saved stations
    private(set) var stations: [Station] = [Station]()
    
    /// Loads previously saved stations
    public init() {
        let fileManager = FileManager.default
        let stationListPath = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory,
            .userDomainMask, true).first?.appending(self.stationListFileName)
        
        if (stationListPath != nil) {
            if (!fileManager.fileExists(atPath: stationListPath!)) {
                // Creat empty file & abort reading
                fileManager.createFile(atPath: stationListPath!,
                                       contents: nil,
                                       attributes: nil)
                return
            }
            if let stationList = NSKeyedUnarchiver.unarchiveObject(withFile: stationListPath!) as? [Station] {
                self.stations = stationList
            } else {
                Debug.log(level: .Error, file: "StationList", msg: "Unable to unarchive station list")
            }
        } else {
            Debug.log(level: .Error, file: "StationList", msg: "Unable to get the path to the station list")
        }
    }
    
    /// Saves current list to file before closing
    deinit {
        let fileManager = FileManager.default
        let stationListPath = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory,
            .userDomainMask, true).first?.appending(self.stationListFileName)
        
        if (stationListPath != nil) {
            // Create empty file to write to
            if (!fileManager.fileExists(atPath: stationListPath!)) {
                fileManager.createFile(atPath: stationListPath!,
                                       contents: nil,
                                       attributes: nil)
            }
            NSKeyedArchiver.archiveRootObject(self.stations, toFile: stationListPath!)
        } else {
            Debug.log(level: .Error, file: "StationList", msg: "Unable to get the path to the station list")
        }
    }
}
