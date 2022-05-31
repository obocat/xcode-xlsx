//
//  main.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 21/5/22.
//

import Foundation
import CoreXLSX
import ColorizeSwift

Terminal().main()

final public class Terminal {

    public enum Terminal: Error, LocalizedError {
        case arguments
        case XLSXInvalid

        public var errorDescription: String? {
            switch self {
            case .arguments:
                return "usage:\txcode-xlsx infile outfile\n\tinfile: XLSX file path.\n\toutfile: Xcode localization resource path."
            case .XLSXInvalid:
                return "XLSX file is corrupted or does not exist."
            }
        }
    }
    
    public func main() {
        do {
            let arguments = CommandLine.arguments
            guard arguments.count == 3 else { throw Terminal.arguments }
            let excelPath = arguments[1]
            let xcodeLocalizationPath = arguments[2]
            guard let file = XLSXFile(filepath: excelPath) else { throw Terminal.XLSXInvalid }
            print("XLSX path selected: \(excelPath.green()).".terminalAction())
            print("Xcode localization path selected: \(xcodeLocalizationPath.green()).".terminalAction())
            try insertTranslations(file: file, xcodeLocalizationPath: xcodeLocalizationPath)
            let congratsText = "Congrats".green().bold() + ". Have a ☕️."
            print(congratsText)
        } catch {
            print(error.localizedDescription.red().bold())
        }
        exit(1)
    }

    private func insertTranslations(file: XLSXFile, xcodeLocalizationPath: String) throws {
        for workbook in try file.parseWorkbooks() {
            for (name, path) in try file.parseWorksheetPathsAndNames(workbook: workbook) {
                guard let name = name?.split(separator: " ").first else { continue }
                print("Adding translations for localization resource \(String(name).green())...".terminalAction())
                let worksheetTranslationManager = try WorksheetTranslationManager(name: String(name), file: file, at: path, xcodeLocalizationPath: xcodeLocalizationPath)
                try worksheetTranslationManager.insertTranslations()
            }
        }
    }
}
