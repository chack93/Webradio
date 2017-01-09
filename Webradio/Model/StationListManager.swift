//
//  StationListManager.swift
//  Webradio
//
//  Created by Christian Hackl on 11/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Foundation
import AppKit

class ArchieveableStationArray: NSObject, NSCoding {
    var stations = [Station]()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        let length = aDecoder.decodeInteger(forKey: "length")
        self.stations = [Station]()
        for i in 0..<length {
            let station = aDecoder.decodeObject(forKey: "station" + i.description) as! Station?
            if station == nil {
                Debug.log(level: .Error, file: "ArchieveableStationArray", msg: "Found empty station at index: " + i.description + "; skipping")
                continue
            }
            self.stations.append(station!)
        }
    }
    
    func encode(with aCoder: NSCoder) {
        let length = self.stations.count
        aCoder.encode(length as Int, forKey: "length")
        for i in 0..<length {
            aCoder.encode(self.stations[i], forKey: "station" + i.description)
        }
    }
}

class StationListManager: NSCoder {
    // - MARK: constants
    private let appSupportSubDir = "/Webradio"
    private let stationListFilename = "/stationList.wrl"
    
    // - MARK: properties
    
    /// List of all saved stations
    var stations = [Station]() {
        didSet {
            self.checkStations()
        }
    }
    var favoriteStations: [Station] {
        get {
            var returnValue = [Station]()
            for station in self.stations {
                if station.favorite {
                    returnValue.append(station)
                }
            }
            return returnValue
        }
    }
    
    // - MARK: Init
    
    /// Loads previously saved stations
    override init() {
        super.init()
        let fileManager = FileManager.default
        // Application Support
        guard let appSupportDir = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory,
            .userDomainMask, true).first else {
                Debug.log(level: .Error, file: self.classDescription.className, msg: "Unable to find Application Support Directory")
                return
        }
        // Application Support/Webradio
        if !fileManager.fileExists(atPath: appSupportDir + self.appSupportSubDir) {
            do {
                try fileManager.createDirectory(atPath: appSupportDir + self.appSupportSubDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Debug.log(level: .Error, file: self.classDescription.className, msg: "Sub directory in Application Support could not be created; " + error.localizedDescription)
                return
            }
        }
        
        // Application Support/Webradio/stationList.wrl
        let stationListPath = appSupportDir + self.appSupportSubDir + self.stationListFilename
        if !fileManager.fileExists(atPath: stationListPath) {
            fileManager.createFile(atPath: stationListPath, contents: nil, attributes: nil)
            return
        }
        
        if let archievableStationList = NSKeyedUnarchiver.unarchiveObject(withFile: stationListPath) as! ArchieveableStationArray? {
            self.stations = archievableStationList.stations
        } else {
            Debug.log(level: .Error, file: self.classDescription.className, msg: "Unable to unarchive station list")
            return
        }
        self.checkStations()
    }
    
    /// Write current station list to file
    func saveStationList() {
        let fileManager = FileManager.default
        // Application Support
        guard let appSupportDir = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory,
            .userDomainMask, true).first else {
                Debug.log(level: .Error, file: self.classDescription.className, msg: "Unable to find Application Support Directory")
                return
        }
        // Application Support/Webradio
        if !fileManager.fileExists(atPath: appSupportDir + self.appSupportSubDir) {
            do {
                try fileManager.createDirectory(atPath: appSupportDir + self.appSupportSubDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Debug.log(level: .Error, file: self.classDescription.className, msg: "Sub directory in Application Support could not be created; " + error.localizedDescription)
                return
            }
        }
        
        // Application Support/Webradio/stationList.wrl
        let stationListPath = appSupportDir + self.appSupportSubDir + self.stationListFilename
        if !fileManager.fileExists(atPath: stationListPath) {
            fileManager.createFile(atPath: stationListPath, contents: nil, attributes: nil)
            return
        }
        let archievableStationArray = ArchieveableStationArray()
        archievableStationArray.stations = self.stations
        NSKeyedArchiver.archiveRootObject(archievableStationArray, toFile: stationListPath)
    }
    
    /// sync index property in each station with array index
    private func checkStations() {
        var defaultFound = false
        for i in 0..<self.stations.count {
            self.stations[i].index = i
            defaultFound = false
            for stream in self.stations[i].streams {
                if stream.isDefault {
                    defaultFound = true
                    break
                }
            }
            if !defaultFound && self.stations[i].streams.count > 0 {
                self.stations[i].streams[0].isDefault = true
            }
        }
    }
    
    // - MARK: Playlist import functions
    
    /// List of all supported playlist interpreter
    class var availableImporter: [String] {
        return ["m3u",
                "m3u8"]
        /* upcomming
         "pls",
         "xspf"]
         */
    }
    
    /** Creates a station object from given playlist
     - parameters:
     - file: path to playlist file, extension of path selects importer
     - returns: A station list, or nil if the playlist can not be read
     */
    class func stationFrom(file: URL) -> [Station]? {
        let fileExt = file.pathExtension
        switch fileExt.lowercased() {
        case "m3u", "m3u8":
            return StationListManager.stationFrom(m3u: file)
        case "pls":
            return nil
        case "xspf":
            return nil
        default:
            return nil
        }
    }
    
    /** Creates a playlist from given stations array
     - parameters:
     - stations: stations that will be exported
     - ofType: file extension of the playlist that should be created
     - returns: The created playlist as a String that can be written to a file
     */
    class func createPlaylistFrom(_ stations: [Station], ofType: String) -> String {
        switch ofType.lowercased() {
        case "m3u", "m3u8":
            return StationListManager.m3uPlaylistFrom(stations)
        case "pls":
            return ""
        case "xspf":
            return ""
        default:
            return ""
        }
    }
    
    /** Creates a station object from a m3u playlist
     - parameters:
     - m3u: path to m3u file
     - returns: A station list, or nil if the playlist can not be read
     
     Will handle simple files as one station with multiple streams.
     Will add new station for each beginning extended information in stream
     */
    class func stationFrom(m3u: URL) -> [Station]? {
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
                            Debug.log(level: .Debug, file: self.classDescription().className, msg: "Created new Station: title=" + newStation!.title + " streams=" + newStation!.streams.description)
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
                    if let lastPathComponent = line.components(separatedBy: "/").last {
                        let streamItem = StreamItem.init(stream: line, title: lastPathComponent)
                        newStation!.streams.append(streamItem)
                    } else {
                        let streamItem = StreamItem.init(stream: line, title: "")
                        newStation!.streams.append(streamItem)
                    }
                    
                }
            }
            // append item in simple m3u or last in extended playlist
            if newStation != nil && newStation!.streams.count > 0 {
                stations.append(newStation!)
                Debug.log(level: .Debug, file: self.classDescription().className, msg: "Created new Station: title=" + newStation!.title + " streams=" + newStation!.streams.description)
            } else {
                Debug.log(level: .Error, file: self.classDescription().className, msg: "Given m3u playlist is empty")
            }
        } catch {
            Debug.log(level: .Error, file: self.classDescription().className, msg: "Unable to read content of m3u file, " + error.localizedDescription)
            return nil
        }
        return stations
    }
    
    /** Creates a m3u playlist from given stations array
     - parameters:
     - stations: stations that will be exported
     - returns: The created playlist as a String that can be written to a file
     */
    class func m3uPlaylistFrom(_ stations: [Station]) -> String{
        if stations.count < 1 {
            return ""
        }
        var playlist = "#EXTM3U"
        for station in stations {
            for stream in station.streams {
                if stream.title.characters.count > 0 {
                    playlist += "\n#EXTINF:-1," + station.title + " - " + stream.title + "\n"
                } else {
                    playlist += "\n#EXTINF:-1," + station.title + "\n"
                }
                playlist += stream.stream
            }
        }
        return playlist
    }
}
