//
//  GenreListHandler.swift
//  Webradio
//
//  Created by Christian Hackl on 10/12/2016.
//  Copyright © 2016 Christian Hackl. All rights reserved.
//

import Foundation

public class GenreListHandler {
    
    private static var genreList: [String] = [String]()
    
    /** Returns a list with genres
     
    Will read the list in application support on first call
     */
    class func getGenreList() -> [String] {
        // read genre list file, if not already
        if (self.genreList.count < 1) {
            let fileManager = FileManager.default
            let listPath = NSSearchPathForDirectoriesInDomains(
                .applicationSupportDirectory,
                .userDomainMask, true).first?.appending("genreslist.txt")
            
            if (listPath == nil) {
                Debug.log(level:.Error, file:"GenreListHandler", msg:"getGenreList: genrelist path does not exist")
                return [String]()
            }
            
            // read file
            if (fileManager.fileExists(atPath: listPath!)) {
                var fileContent = ""
                
                do {
                    try fileContent = String.init(contentsOfFile: listPath!)
                } catch {
                    Debug.log(level:.Error, file:"GenreListHandler", msg:"getGenreList: can not read file content" + error.localizedDescription)
                }
                self.genreList = fileContent.components(separatedBy: "\n") as [String]
            }
        }
        return self.genreList
    }
    
    /** Add given genre to list
     
    - parameters:
        - genre: New genre as String
    
    
    Will only add to list if not already defined. If a new genre is added succesfully, the whole list will be saved to the genre list file
    */
    class func addToGenresList(genre: String) {
        if (self.genreList.contains(genre)) {
            return
        }
        self.genreList.append(genre)
        
        // save to file
        let fileManager = FileManager.default
        let listPath = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory,
            .userDomainMask, true).first?.appending("genreslist.txt")
        
        if (listPath == nil) {
            Debug.log(level:.Error, file:"GenreListHandler", msg:"addToGenresList: genrelist path does not exist")
            return
        }
        
        // create file content
        var fileContent = ""
        for genre in self.genreList {
            fileContent.append(genre + "\n")
        }
        fileManager.createFile(atPath: listPath!,
                               contents: nil,
                               attributes: nil)
        do {
            try fileContent.write(toFile: listPath!,
                                  atomically: true,
                                  encoding: String.Encoding.utf8)
        } catch {
            Debug.log(level:.Error, file:"GenreListHandler", msg:"addToGenresList: unable to write to genre list file: " + error.localizedDescription)
        }
    }
    
    
}
