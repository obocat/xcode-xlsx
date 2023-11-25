//
//  File.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 1/6/22.
//

import Foundation
import CoreXLSX

final class LocalizationImporterController: Algorithm {
    weak var delegate: Terminal?

    public enum ProcessError: Error, LocalizedError {
        case arguments
        case invalidXLSX

        public var errorDescription: String? {
            switch self {
            case .arguments:
                return "usage:\txcode-xlsx infile outfile\n\tinfile: XLSX file path.\n\toutfile: Xcode localization resource path."
            case .invalidXLSX:
                return "XLSX file is corrupted or does not exist."
            }
        }
    }

    /// Runs the localization import process based on the provided command-line arguments.
    /// - Parameters:
    ///   - arguments: An array of command-line arguments containing the XLSX file path and Xcode localization resource path.
    func run(arguments: [String]) {
        do {
            guard arguments.count == 3,
                  let excelPath = arguments[safe: 1],
                  let xcodePath = arguments[safe: 2]
            else { throw ProcessError.arguments }
            guard let file = XLSXFile(filepath: excelPath) else { throw ProcessError.invalidXLSX }
            delegate?.showAction("XLSX path selected: \(excelPath.green()).")
            delegate?.showAction("Xcode localization path selected: \(xcodePath.green()).")
            try importTranslations(file: file, xcodePath: xcodePath)
            let congratsText = "Congrats".green().bold() + ". Have a ☕️."
            delegate?.show(congratsText)
        } catch {
            delegate?.showError(error)
        }
    }

    /// Imports translations from the provided XLSX file to the specified Xcode localization path.
    /// - Parameters:
    ///   - file: The XLSX file containing translations.
    ///   - xcodePath: The path to the Xcode localization resource directory.
    /// - Throws: An error if there is an issue parsing or writing the localizations.
    private func importTranslations(file: XLSXFile, xcodePath: String) throws {
        for workbook in try file.parseWorkbooks() {
            for (name, path) in try file.parseWorksheetPathsAndNames(workbook: workbook) {
                guard let name = name?.split(separator: " ").first else { continue }
                delegate?.showAction("Adding translations for localization resource \(String(name).green())...")
                let localizationController = LocalizationController(localizationResourceName: String(name),
                                                                    xlsxFile: file,
                                                                    workSheetPath: path,
                                                                    xcodeLocalizationMainPath: xcodePath)
                localizationController.delegate = delegate
                try localizationController.parse()
                try localizationController.write()
            }
        }
    }

}
