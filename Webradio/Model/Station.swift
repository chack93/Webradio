//
//  Station.swift
//  Webradio
//
//  Created by Christian Hackl on 10/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Foundation
import AppKit

public struct ScheduleItem {
    public var start: String
    public var end: String
    public var description: String
}

public class Station {
    public var title: String = ""
    public var genre: String = "" {
        didSet {
            
        }
    }
    public var image: NSImage = NSImage.init(named: "DefaultStationIcon")!
    public var streams: [NSURL] = []
    public var description: String = ""
    public var favorite: Bool = false
    public var scheduleItems: [ScheduleItem] = [ScheduleItem]()
    
    public init() {
    }
    
    public init(title: String,
                genre: String,
                image: NSImage,
                streams: [NSURL],
                description: String,
                favorite: Bool,
                scheduleItems: [ScheduleItem]) {
        self.title = title
        self.genre = genre
        self.image = image
        self.streams = streams
        self.description = description
        self.favorite = favorite
        self.scheduleItems = scheduleItems
    }
}
