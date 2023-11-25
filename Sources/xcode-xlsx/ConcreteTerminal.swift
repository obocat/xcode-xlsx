//
//  ConcreteTerminal.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 1/6/22.
//

import Foundation
import ColorizeSwift

final public class ConcreteTerminal: Terminal {
    
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
