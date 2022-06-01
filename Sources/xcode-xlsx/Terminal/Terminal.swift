//
//  File.swift
//  
//
//  Created by Daniel Toranzo Pérez on 1/6/22.
//

import Foundation
import ColorizeSwift

// MARK: TerminalAction protocol

@objc protocol TerminalAction {
    func show(_ text: String)
    func showAction(_ text: String)
    func showError(_ error: Error)
}

final public class Terminal {

    var algorithm: Algorithm? {
        didSet {
            algorithm?.delegate = self
        }
    }

    func execute(arguments: [String] = CommandLine.arguments) {
        algorithm?.run(arguments: arguments)
        exit(1)
    }

}

// MARK: TerminalAction delegate

extension Terminal: TerminalAction {

    func show(_ text: String) {
        print(text)
    }

    func showAction(_ text: String) {
        print(text.terminalAction())
    }

    func showError(_ error: Error) {
        print(error.localizedDescription.red().bold())
    }

}
