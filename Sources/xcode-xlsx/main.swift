//
//  main.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 21/5/22.
//

import Foundation
import CoreXLSX

enum MainError: Error, LocalizedError {
    case arguments
    case excelInvalid
    
    public var errorDescription: String? {
        switch self {
        case .arguments:
            return "usage: xcode-xlsx infile outfile\n\tinfile: XLSX file path.\n\toutfile: Xcode localization resource path."
        case .excelInvalid:
            return "XLSX file is corrupted or does not exist."
        }
    }
}

let arguments = CommandLine.arguments

main()

private func main() {
    do {
        guard arguments.count == 3 else { throw MainError.arguments }
        let excelPath = arguments[1]
        let xcodeLocalizationPath = arguments[2]
        guard let file = XLSXFile(filepath: excelPath) else { throw MainError.excelInvalid }
        print("XLSX path selected: \(excelPath.terminalColor(color: .green)).")
        print("Xcode localization path selected: \(xcodeLocalizationPath.terminalColor(color: .green)).\n")
        try insertTranslations(file: file, xcodeLocalizationPath: xcodeLocalizationPath)
        let congratsText = "Congrats".terminalColor(color: .green)
        print("\(congratsText). Have a ☕️.")
    } catch {
        print(error.localizedDescription)
    }
}

private func insertTranslations(file: XLSXFile, xcodeLocalizationPath: String) throws {
    for workbook in try file.parseWorkbooks() {
        for (name, path) in try file.parseWorksheetPathsAndNames(workbook: workbook) {
            guard let name = name?.split(separator: " ").first else { continue }
            print("Adding translations for localization resource \(String(name).terminalColor(color: .green))...\n")
            let worksheetTranslationManager = try WorksheetTranslationManager(name: String(name), file: file, at: path, xcodeLocalizationPath: xcodeLocalizationPath)
            try worksheetTranslationManager.insertTranslations()
        }
    }
}
