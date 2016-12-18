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
    // - MARK: constants
    
    private let stationListFileName = "stationList.wrl"
    
    // - MARK: properties
    
    /// List of all saved stations
    public var stations: [Station] = [Station]()
    
    // - MARK: Init/Deinit
    
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
    
    // - MARK: Import Station from playlists
    
    /** Creates a station object from a m3u playlist
    - parameters:
        - m3u: path to m3u file
    - returns: A station list, or nil if the playlist can not be read
     
    Will handle simple files as one station with multiple streams.
    Will add new station for each beginning extended information in stream
    */
    public class func stationFrom(m3u: URL) -> [Station]? {
        var stations: [Station] = [Station]()
        var newStation: Station? = nil
        do {
            let file = try String.init(contentsOf: m3u)
            let splitFile = file.components(separatedBy: ["\n", "\r"])
            // go trough each line & get streams / Station name
            for var line in splitFile {
                // jump empty / first line in extended m3u
                if line.characters.count < 1 ||
                    line.lowercased().range(of: "extm3u") != nil {
                    continue
                }
                // add new station with extended information
                if (line.lowercased().range(of: "extinf") != nil) {
                    if let titleStart = line.range(of: ",") {
                        let title = line.substring(from: titleStart.upperBound)
                        // append created station to list & create new one
                        if newStation != nil {
                            stations.append(newStation!)
                            Debug.log(level: .Debug, file: "StationList", msg: "Created new Station: title=" + newStation!.title + " streams=" + newStation!.streams.description)
                            newStation = nil
                        }
                        newStation = Station.init()
                        newStation!.title = title
                    }
                } else {
                    // create new one if no title is given
                    if (newStation == nil) {
                        newStation = Station.init()
                    }
                    if let stream = URL.init(string: line) {
                        newStation!.streams.append(stream)
                    }
                }
            }
            // append item in simple m3u or last in extended playlist
            if newStation != nil && newStation!.streams.count > 0 {
                stations.append(newStation!)
                Debug.log(level: .Debug, file: "StationList", msg: "Created new Station: title=" + newStation!.title + " streams=" + newStation!.streams.description)
            } else {
                Debug.log(level: .Error, file: "StationList", msg: "Given m3u playlist is empty")
            }
        } catch {
            Debug.log(level: .Error, file: "StationList", msg: "Unable to read content of m3u file, " + error.localizedDescription)
            return nil
        }
        return stations
    }
}
