//
//  Terminal.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 25/11/23.
//

import Foundation

// MARK: Terminal protocol

/// Protocol defining the interface for interacting with the terminal.
protocol Terminal: AnyObject {
    /// Displays a message in the terminal.
    /// - Parameter text: The text to be displayed.
    func show(_ text: String)
    /// Displays an action in the terminal.
    /// - Parameter text: The text of the action to be displayed.
    func showAction(_ text: String)
    /// Displays an error in the terminal.
    /// - Parameter error: The error to be displayed.
    func showError(_ error: Error)
}
