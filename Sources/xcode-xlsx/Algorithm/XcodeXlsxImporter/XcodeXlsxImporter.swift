//
//  File.swift
//  
//
//  Created by Daniel Toranzo Pérez on 1/6/22.
//

import Foundation
import CoreXLSX

final class XcodeXlsxImporter: Algorithm {

    weak var delegate: TerminalAction?

    public enum ProcessError: Error, LocalizedError {
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

    func run(arguments: [String]) {
        do {
            guard arguments.count == 3 else { throw ProcessError.arguments }
            let excelPath = arguments[1]
            let xcodePath = arguments[2]
            guard let file = XLSXFile(filepath: excelPath) else { throw ProcessError.XLSXInvalid }
            delegate?.showAction("XLSX path selected: \(excelPath.green()).")
            delegate?.showAction("Xcode localization path selected: \(xcodePath.green()).")
            try insertTranslations(file: file, xcodePath: xcodePath)
            let congratsText = "Congrats".green().bold() + ". Have a ☕️."
            delegate?.show(congratsText)
        } catch {
            delegate?.showError(error)
        }
    }

    private func insertTranslations(file: XLSXFile, xcodePath: String) throws {
        for workbook in try file.parseWorkbooks() {
            for (name, path) in try file.parseWorksheetPathsAndNames(workbook: workbook) {
                guard let name = name?.split(separator: " ").first else { continue }
                delegate?.showAction("Adding translations for localization resource \(String(name).green())...")
                let localizationController = try LocalizationController(name: String(name), file: file, at: path, xcodePath: xcodePath)
                try localizationController.parse()
                localizationController.writeLocalizations()
            }
        }
    }

}
