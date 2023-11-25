//
//  Algorithm.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 1/6/22.
//

import Foundation

// MARK: Algorithm protocol

/// Protocol defining the interface for an algorithm.
protocol Algorithm {
    /// Runs the algorithm with the provided command-line arguments.
    /// - Parameter arguments: An array of command-line arguments.
    func run(arguments: [String])
}
