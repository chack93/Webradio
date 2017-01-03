//
//  Station.swift
//  Webradio
//
//  Created by Christian Hackl on 10/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Foundation
import AppKit

class ScheduleItem: NSObject, NSCoding {
    dynamic var start: String = ""
    dynamic var end: String = ""
    dynamic var text: String = ""
    
    required convenience init(coder decoder: NSCoder) {
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

class StreamItem: NSObject, NSCoding {
    dynamic var stream: String = ""
    dynamic var title: String = ""
    dynamic var isDefault: Bool = false
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        if let stream = decoder.decodeObject(forKey: "stream") as? String {
            self.stream = stream
        }
        if let title = decoder.decodeObject(forKey: "title") as? String {
            self.title = title
        }
        self.isDefault = decoder.decodeBool(forKey: "isDefault")
    }
    
    convenience override init() {
        self.init(stream: "", title: "")
    }
    
    convenience init(stream: String) {
        self.init(stream: stream, title: "")
    }
    
    init(stream: String, title: String) {
        self.stream = stream
        self.title = title
        self.isDefault = false
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.stream, forKey: "stream")
        coder.encode(self.title, forKey: "title")
        coder.encode(self.isDefault, forKey: "isDefault")
    }
}

class Station: NSObject, NSCoding {
    dynamic var index: Int = -1
    dynamic var title: String = ""
    dynamic var genre: String = "" {
        didSet {
            
        }
    }
    dynamic var image: NSImage = NSImage.init(named: "DefaultStationIcon")!
    dynamic var streams: [StreamItem] = [StreamItem]()
    dynamic var text: String = ""
    dynamic var favorite: Bool = false
    dynamic var scheduleItems: [ScheduleItem] = [ScheduleItem]()
    
    override init() {
        super.init()
    }
    
    init(title: String?,
                genre: String?,
                image: NSImage?,
                streams: [StreamItem],
                text: String?,
                favorite: Bool?,
                scheduleItems: [ScheduleItem]?) {
        super.init()
        self.title = title != nil ? title! : ""
        self.genre = genre != nil ? genre! : ""
        self.image = image != nil ? image! : NSImage.init(named: "DefaultStationIcon")!
        // Set default stream if not defined
        var defaultStreamSet = false
        for stream in streams {
            if stream.isDefault && !defaultStreamSet {
                defaultStreamSet = true
            } else {
                stream.isDefault = false
            }
        }
        if !defaultStreamSet {  // Set first as default
            if let first = streams.first {
                first.isDefault = true
            }
        }
        self.streams = streams
        self.text = text != nil ? text! : ""
        self.favorite = favorite != nil ? favorite! : false
        self.scheduleItems = scheduleItems != nil ? scheduleItems! : [ScheduleItem]()
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        if let index = decoder.decodeObject(forKey: "index") as? Int {
            self.index = index
        }
        if let title = decoder.decodeObject(forKey: "title") as? String {
            self.title = title
        }
        if let genre = decoder.decodeObject(forKey: "genre") as? String {
            self.genre = genre
        }
        if let image = decoder.decodeObject(forKey: "image") as? NSImage {
            self.image = image
        }
        if let streams = decoder.decodeObject(forKey: "streams") as? [StreamItem] {
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
        coder.encode(self.index, forKey: "index")
        coder.encode(self.title, forKey: "title")
        coder.encode(self.genre, forKey: "genre")
        coder.encode(self.image, forKey: "image")
        coder.encode(self.text, forKey: "text")
        coder.encode(self.favorite, forKey: "favorite")
        coder.encode(self.streams, forKey: "streams")
        coder.encode(self.scheduleItems, forKey: "scheduleItems")
    }
}
