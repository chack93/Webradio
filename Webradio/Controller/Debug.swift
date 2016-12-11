//
//  Debug.swift
//  Webradio
//
//  Created by Christian Hackl on 10/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Foundation

public enum ErrorLvl: String{
    case Debug = "DEBUG"
    case Error = "ERROR"
}

public class Debug {
    
    /**
     Logs messages formatted to the debug console
     
     - parameters:
        - level: 
            Debug = Print to debug console only

            Error = Error will be written to error.log
     
        - file:  The filename in which the error occoured in
        - msg:   The message to log
     */
    public class func log(level: ErrorLvl, file: String, msg: String) {
        let timestamp = NSDate.init().description
        let formatedMsg = timestamp +
            " <" + level.rawValue +
            "> File: " + file +
            ": " + msg
        debugPrint(formatedMsg);
        
        if (level == .Debug) {
            return
        }
        
        // Add to error log
        let fileManager = FileManager.default
        let errorLogPath = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory,
            .userDomainMask, true).first?.appending("error.log")
        
        if (errorLogPath != nil) {
            if (!fileManager.fileExists(atPath: errorLogPath!)) {
                fileManager.createFile(atPath: errorLogPath!,
                                       contents: nil,
                                       attributes: nil)
            }
            do {
                let filecontent = try String.init(contentsOfFile: errorLogPath!) + "\n" + formatedMsg
                try filecontent.write(toFile: errorLogPath!, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                
            }
        }
    }
}
