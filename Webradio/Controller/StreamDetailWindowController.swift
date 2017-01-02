//
//  StreamDetailWindow.swift
//  Webradio
//
//  Created by Christian Hackl on 26/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Cocoa

class TableItem: NSObject, NSCoding {

    dynamic var title = ""
    dynamic var stream = ""
    dynamic var isDefault = false {
        didSet {
            if !self.isDefault {
                return
            }
            if let callback = self.isDefaultCallback {
                callback(self)
            }
        }
    }
    var isDefaultCallback: ((TableItem) -> Void)?
    
    init(title: String, stream: String, isDefault: Bool, callback: @escaping (TableItem) -> Void) {
        self.title = title
        self.stream = stream
        self.isDefault = isDefault
        self.isDefaultCallback = callback
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as! String
        stream = aDecoder.decodeObject(forKey: "stream") as! String
        isDefault = aDecoder.decodeObject(forKey: "isDefault") as! Bool
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(stream, forKey: "stream")
        aCoder.encode(isDefault, forKey: "isDefault")
    }

}

class StreamDetailWindowController: NSWindowController {
    
    @IBOutlet weak var streamTable: NSTableView!
    @IBOutlet weak var streamsArrayController: NSArrayController!
    
    override var windowNibName: String? {
        return "StreamDetailWindow"
    }
    
    var streamItemsSet = false
    var streamItems = [StreamItem]() {
        didSet {
            if self.streamItemsSet {
                return
            }
            streamItemsSet = true
            for item in streamItems {
                let tblItem = TableItem.init(title: item.title, stream: item.stream, isDefault: item.isDefault, callback: self.setDefault)
                self.tableItems.append(tblItem)
            }
        }
    }
    dynamic var tableItems = [TableItem]()
    
    func setDefault(defaultItem: TableItem) {
        for item in self.tableItems {
            if item == defaultItem {
                continue
            } else {
                item.isDefault = false
            }
        }
        self.streamTable.reloadData()
    }
    
    @IBAction func closeWindow(_: NSButton) {
        self.streamItems.removeAll()
        for item in self.tableItems {
            
                let newStrItm = StreamItem.init()
                newStrItm.title = item.title
                newStrItm.stream = item.stream
                newStrItm.isDefault = item.isDefault
                self.streamItems.append(newStrItm)
            
        }
        self.window!.endEditing(for: self)
        window!.sheetParent!.endSheet(window!, returnCode: NSModalResponseOK)
    }
    
    @IBAction func addItem(_: NSButton) {
        let newItem = TableItem.init(title: "Title", stream: "", isDefault: false, callback: self.setDefault)
        self.tableItems.append(newItem)
    }
    
    @IBAction func removeSelected(_: NSButton) {
        let idx = self.streamsArrayController.selectionIndex
        if idx > self.tableItems.count {
            return
        }
        self.tableItems.remove(at: idx)
        var defaultExist = false
        for item in self.tableItems {
            if item.isDefault {
                defaultExist = true
                break
            }
        }
        if !defaultExist && self.tableItems.count > 0 {
            self.tableItems[0].isDefault = true
        }
        self.window!.viewsNeedDisplay = true
    }
}
