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
    dynamic public var start: String = ""
    dynamic public var end: String = ""
    dynamic public var text: String = ""
    
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

public class StreamItem: NSCoder {
    dynamic public var stream: URL?
    dynamic public var title: String = ""
    dynamic public var isDefault: Bool = false
    
    public required convenience init(coder decoder: NSCoder) {
        self.init()
        if let stream = decoder.decodeObject(forKey: "stream") as? URL {
            self.stream = stream
        }
        if let title = decoder.decodeObject(forKey: "title") as? String {
            self.title = title
        }
        if let isDefault = decoder.decodeObject(forKey: "isDefault") as? Bool {
            self.isDefault = isDefault
        }
    }
    
    public convenience override init() {
        self.init(stream: nil, title: "")
    }
    
    public convenience init(stream: URL?) {
        self.init(stream: stream, title: "")
    }
    
    public init(stream: URL?, title: String) {
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

public class Station: NSCoder {
    dynamic public var title: String = ""
    dynamic public var genre: String = "" {
        didSet {
            
        }
    }
    dynamic public var image: NSImage = NSImage.init(named: "DefaultStationIcon")!
    dynamic public var streams: [StreamItem] = []
    dynamic public var text: String = ""
    dynamic public var favorite: Bool = false
    dynamic public var scheduleItems: [ScheduleItem] = [ScheduleItem]()
    
    public override init() {
        super.init()
    }
    
    public init(title: String?,
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
        coder.encode(self.title, forKey: "title")
        coder.encode(self.genre, forKey: "genre")
        coder.encode(self.image, forKey: "image")
        coder.encode(self.streams, forKey: "streams")
        coder.encode(self.text, forKey: "text")
        coder.encode(self.favorite, forKey: "favorite")
        coder.encode(self.scheduleItems, forKey: "scheduleItems")
    }
}
