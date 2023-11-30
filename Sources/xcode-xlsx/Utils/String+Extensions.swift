//
//  String+Extensions.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 21/5/22.
//

import Foundation
import ColorizeSwift

extension String {
    
    /// Extension on String to format it as a terminal action.
    /// - Returns: A formatted string for a terminal action.
    public func terminalAction() -> String {
        return "==>".reset().blue() + " " + self.bold()
    }
    
}
