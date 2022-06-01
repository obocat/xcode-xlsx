//
//  WorksheetTranslationManager.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 21/5/22.
//

import Foundation
import CoreXLSX

final class LocalizationController {

    class Localization: CustomStringConvertible {
        private let key: String
        private let value: String

        var description: String {
            ("\"\(key)\" = \"\(value)\";")
        }

        init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }

    enum ParseError: Error, LocalizedError {
        case sharedStrings
        case data

        public var errorDescription: String? {
            switch self {
            case .sharedStrings:
                return "XLSX shared strings not found"
            case .data:
                return "XLSX data error"
            }
        }
    }

    let name: String
    let file: XLSXFile
    let path: String
    let worksheet: Worksheet
    let sharedStrings: SharedStrings
    let xcodePath: String
    var localizations: [String: [Localization]] = [:]
    
    init(name: String, file: XLSXFile, at: String, xcodePath: String) throws {
        self.name = name
        self.file = file
        self.path = at
        self.worksheet = try file.parseWorksheet(at: self.path)
        guard let sharedStringsTemp = try file.parseSharedStrings() else { throw LocalizationController.ParseError.sharedStrings }
        self.sharedStrings = sharedStringsTemp
        self.xcodePath = xcodePath
    }

    // MARK: Public Methods

    /// Parses all localizations.
    /// - Postcondition: After completing this method the parsed localizations will be stored in `localizations` dictionary property.
    func parse() throws {
        guard let data = worksheet.data else { throw LocalizationController.ParseError.data }
        guard let keyRow = data.rows.first else { return }
        let keysArray = keyRow.cells.dropFirst().compactMap { $0.stringValue(sharedStrings) }
        keysArray.forEach {
            localizations[$0] = []
        }
        let dataArray = data.rows.dropFirst()
        for row in dataArray {
            parse(rowCells: row.cells, keysArray: keysArray)
        }
    }

    /// Writes all parsed localizations.
    /// - Precondition: `parse()` should be called first.
    /// - Postcondition: After completing this method the parsed localizations will be written to the corresponding `.strings` files.
    func writeLocalizations() {
        for (key, localizations) in localizations {
            localizations.forEach { write(key: key, localization: $0) }
        }
    }

    // MARK: Private Methods

    private func parse(rowCells: [Cell], keysArray: [String]) {
        guard let key = rowCells.first?.stringValue(sharedStrings) else { return }
        for (index, cell) in rowCells.dropFirst().enumerated() {
            if let value = cell.stringValue(sharedStrings) {
                let localization = Localization(key: key, value: value)
                localizations[keysArray[index]]?.append(localization)
            }
        }
    }

    private func write(key: String, localization: Localization) {
        let value = localization.description
        let path = URL(fileURLWithPath: "\(xcodePath)/\(key)/\(name)")
        print("Writing to \(path.path.green()):".terminalAction())
        print("\(value)")
        do {
            try value.write(to: path)
        } catch {
            let failed = "Failed".red().appending("\n")
            print(failed)
        }
    }

}
