//
//  File.swift
//  
//
//  Created by Daniel Toranzo Pérez on 1/6/22.
//

import Foundation

@objc protocol Algorithm {
    weak var delegate: TerminalAction? { get set }
    func run(arguments: [String])
}
