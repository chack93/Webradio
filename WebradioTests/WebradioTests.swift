//
//  WebradioTests.swift
//  WebradioTests
//
//  Created by Christian Hackl on 10/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import XCTest
@testable import Webradio

class WebradioTests: XCTestCase {
    let stationListClass = StationList.init()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // - MARK: helper functions 
    
    func playlistPathOf(file: String) -> URL? {
        let testfileFolderName = "testfiles"
        let unitTestBundle = Bundle(for: NSClassFromString("WebradioTests.WebradioTests")!)
        let fileNameSplit = file.components(separatedBy: ".")
        let name = fileNameSplit[0]
        let ext = fileNameSplit[1]
        let playlistPath = unitTestBundle.url(forResource: name, withExtension: ext, subdirectory: testfileFolderName)
        
        if (playlistPath == nil) {
            Debug.log(level: .Test, file: "WebradioTests", msg: "playlist testfile: " + name + "." + ext + " does not exist")
            return nil
        }
        return playlistPath
    }
    
    func compare(newStations: [Station], correctStations: [Station], file: String) {
        for i in 0 ..< correctStations.count {
            XCTAssertEqual(correctStations[i].title, newStations[i].title, "Station title of: " + i.description + " element not equal")
            
            XCTAssertEqual(correctStations[i].genre, newStations[i].genre, "Station genre of: " + i.description + " element not equal")
            
            XCTAssertEqual(correctStations[i].text, newStations[i].text, "Station text of: " + i.description + " element not equal")
            
            XCTAssertEqual(correctStations[i].favorite, newStations[i].favorite, "Station favorite of: " + i.description + " element not equal")
            
            for j in 0 ..< correctStations[i].streams.count {
                XCTAssertEqual(correctStations[i].streams[j].stream, newStations[i].streams[j].stream, "Station streams of: " + i.description + " item: " + j.description + " element not equal")
            }
            
            for j in 0 ..< correctStations[i].scheduleItems.count {
                XCTAssertEqual(correctStations[i].scheduleItems[j].start, newStations[i].scheduleItems[j].start, "Station start of: " + i.description + " item: " + j.description + " element not equal")
                
                XCTAssertEqual(correctStations[i].scheduleItems[j].end, newStations[i].scheduleItems[j].end, "Station end of: " + i.description + " item: " + j.description + " element not equal")
                
                XCTAssertEqual(correctStations[i].scheduleItems[j].text, newStations[i].scheduleItems[j].text, "Station text of: " + i.description + " item: " + i.description + " element not equal")
            }
        }
    }
    
    // MARK: - M3U import tests
    
    func testOpenSimpleM3U() {
        let streamItem = StreamItem.init(stream: URL.init(string: "http://detektor.fm/stream/mp3/wort/")!)
        let correctStations: [Station] = [
        Station.init(title: nil,
                     genre: nil,
                     image: nil,
                     streams: [streamItem],
                     text: nil,
                     favorite: nil,
                     scheduleItems: nil)]
        let fileName = "tf_simple.m3u"
        
        if let playlistPath = self.playlistPathOf(file: fileName) {
            let newStations = StationList.stationFrom(m3u: playlistPath)
            XCTAssertNotNil(newStations, "created station is empty")
            self.compare(newStations: newStations!, correctStations: correctStations, file: fileName)
        }
    }
    
    func testOpenMultipleM3U() {
        let streamItem1 = StreamItem.init(stream: URL.init(string: "http://streaming202.radionomy.com:80/Music-Box-Radio")!)
        let streamItem2 = StreamItem.init(stream: URL.init(string: "http://streaming210.radionomy.com:80/Music-Box-Radio")!)
        let streamItem3 = StreamItem.init(stream: URL.init(string: "http://streaming208.radionomy.com:80/Music-Box-Radio")!)
        let correctStations: [Station] = [
            Station.init(title: nil,
                         genre: nil,
                         image: nil,
                         streams: [streamItem1,
                                   streamItem2,
                                   streamItem3],
                         text: nil,
                         favorite: nil,
                         scheduleItems: nil)]
        let fileName = "tf_multiple.m3u"
        
        if let playlistPath = self.playlistPathOf(file: fileName) {
            let newStations = StationList.stationFrom(m3u: playlistPath)
            XCTAssertNotNil(newStations, "created station is empty")
            self.compare(newStations: newStations!, correctStations: correctStations, file: fileName)
        }
    }
    
    func testOpenExtendedM3U() {
        let streamItem = StreamItem.init(stream: URL.init(string: "http://detektor.fm/stream/mp3/wort/")!)
        let correctStations: [Station] = [
            Station.init(title: "Detektor.fm Wortstream",
                         genre: nil,
                         image: nil,
                         streams: [streamItem],
                         text: nil,
                         favorite: nil,
                         scheduleItems: nil)]
        let fileName = "tf_extended.m3u"
        
        if let playlistPath = self.playlistPathOf(file: fileName) {
            let newStations = StationList.stationFrom(m3u: playlistPath)
            XCTAssertNotNil(newStations, "created station is empty")
            self.compare(newStations: newStations!, correctStations: correctStations, file: fileName)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
