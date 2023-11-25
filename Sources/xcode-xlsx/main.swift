//
//  main.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 21/5/22.
//

import Foundation

let terminal = ConcreteTerminal()
let localizationImporterController = LocalizationImporterController()
localizationImporterController.delegate = terminal
localizationImporterController.run(arguments: CommandLine.arguments)
exit(1)
