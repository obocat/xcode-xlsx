//
//  Url+Extensions.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 25/11/23.
//

import Foundation

extension URL {
    
    /// Extension on URL to erase the content of the file it points to.
    /// - Throws: An error if there is an issue with file handling or truncating the file.
    func eraseContent() throws {
        let handle = try FileHandle(forWritingTo: self)
        handle.truncateFile(atOffset: 0)
        handle.closeFile()
    }
    
}
