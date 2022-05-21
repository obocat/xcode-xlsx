//
//  String+Extensions.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 21/5/22.
//

import Foundation

enum Colors: String {
    case reset = "\u{001B}[0;0m"
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
}

extension String {
    
    func write(to: URL) throws {
        let handle = try FileHandle(forWritingTo: to)
        handle.seekToEndOfFile()
        handle.write(self.data(using: .utf8)!)
        handle.closeFile()
    }
    
    var appendBreakToBothEnds: String {
        ("\n\(self)\n")
    }
    
    func terminalColor(color: Colors) -> String {
        return "\(color.rawValue)\(self)\(Colors.reset.rawValue)"
    }
    
}
