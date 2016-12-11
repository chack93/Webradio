//
//  Station.swift
//  Webradio
//
//  Created by Christian Hackl on 10/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Foundation
import AppKit

public class ScheduleItem: NSCoder {
    public var start: String = ""
    public var end: String = ""
    public var text: String = ""
    
    public required convenience init(coder decoder: NSCoder) {
        self.init()
        if let start = decoder.decodeObject(forKey: "start") as? String {
            self.start = start
        }
        if let end = decoder.decodeObject(forKey: "end") as? String {
            self.end = end
        }
        if let text = decoder.decodeObject(forKey: "text") as? String {
            self.text = text
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.start, forKey: "start")
        coder.encode(self.end, forKey: "end")
        coder.encode(self.text, forKey: "text")
    }
}

public class Station: NSCoder {
    public var title: String = ""
    public var genre: String = "" {
        didSet {
            
        }
    }
    public var image: NSImage = NSImage.init(named: "DefaultStationIcon")!
    public var streams: [NSURL] = []
    public var text: String = ""
    public var favorite: Bool = false
    public var scheduleItems: [ScheduleItem] = [ScheduleItem]()
    
    public override init() {
        super.init()
    }
    
    public init(title: String,
                genre: String,
                image: NSImage,
                streams: [NSURL],
                text: String,
                favorite: Bool,
                scheduleItems: [ScheduleItem]) {
        super.init()
        self.title = title
        self.genre = genre
        self.image = image
        self.streams = streams
        self.text = text
        self.favorite = favorite
        self.scheduleItems = scheduleItems
    }
    
    public required convenience init(coder decoder: NSCoder) {
        self.init()
        if let title = decoder.decodeObject(forKey: "title") as? String {
            self.title = title
        }
        if let genre = decoder.decodeObject(forKey: "genre") as? String {
            self.genre = genre
        }
        if let image = decoder.decodeObject(forKey: "image") as? NSImage {
            self.image = image
        }
        if let streams = decoder.decodeObject(forKey: "streams") as? [NSURL] {
            self.streams = streams
        }
        if let text = decoder.decodeObject(forKey: "text") as? String {
            self.text = text
        }
        if let favorite = decoder.decodeObject(forKey: "favorite") as? Bool {
            self.favorite = favorite
        }
        if let scheduleItems = decoder.decodeObject(forKey: "scheduleItems") as? [ScheduleItem] {
            self.scheduleItems = scheduleItems
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.title, forKey: "title")
        coder.encode(self.genre, forKey: "genre")
        coder.encode(self.image, forKey: "image")
        coder.encode(self.streams, forKey: "streams")
        coder.encode(self.text, forKey: "text")
        coder.encode(self.favorite, forKey: "favorite")
        coder.encode(self.scheduleItems, forKey: "scheduleItems")
    }
}
