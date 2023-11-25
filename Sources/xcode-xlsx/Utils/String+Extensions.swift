//
//  String+Extensions.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 21/5/22.
//

import Foundation
import ColorizeSwift

extension String {
    
    /// Extension on String to write its content to a specified URL.
    /// - Parameter to: The URL where the content should be written.
    /// - Throws: An error if there is an issue with file handling or encoding.
    func write(to: URL) throws {
        let handle = try FileHandle(forWritingTo: to)
        handle.seekToEndOfFile()
        handle.write(self.data(using: .utf8)!)
        handle.closeFile()
    }

    /// Extension on String to format it as a terminal action.
    /// - Returns: A formatted string for a terminal action.
    public func terminalAction() -> String {
        return "==>".reset().blue() + " " + self.bold()
    }
    
}
