//
//  String+Extensions.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 21/5/22.
//

import Foundation
import ColorizeSwift

extension String {
    
    func write(to: URL) throws {
        let handle = try FileHandle(forWritingTo: to)
        handle.seekToEndOfFile()
        handle.write(self.data(using: .utf8)!)
        handle.closeFile()
    }

    public func terminalAction() -> String {
        return "==>".reset().blue() + " " + self.bold()
    }
    
}
