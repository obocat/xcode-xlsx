//
//  Collection+Extensions.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 25/11/23.
//

import Foundation

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
