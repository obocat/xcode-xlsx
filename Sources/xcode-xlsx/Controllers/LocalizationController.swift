//
//  LocalizationController.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 21/5/22.
//

import Foundation
import CoreXLSX

final class LocalizationController {
    weak var delegate: Terminal?
    
    private let xlsxFile: XLSXFile
    private let localizationResourceName: String
    private let xcodeLocalizationMainPath: String
    private let workSheetPath: String
    private var localizationsDictionary: [String: [String: String]] = [:]

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

    init(localizationResourceName: String, xlsxFile: XLSXFile, workSheetPath: String, xcodeLocalizationMainPath: String) {
        self.localizationResourceName = localizationResourceName
        self.xlsxFile = xlsxFile
        self.workSheetPath = workSheetPath
        self.xcodeLocalizationMainPath = xcodeLocalizationMainPath
    }

    // MARK: Public Methods

    /// Parses all localizations.
    /// - Postcondition: After completing this method the parsed localizations will be stored in `localizations` dictionary property.
    /// - Throws: An error if there is an issue parsing the files.
    func parse() throws {
        let worksheet = try xlsxFile.parseWorksheet(at: workSheetPath)
        guard let sharedStrings = try xlsxFile.parseSharedStrings() else { throw ParseError.sharedStrings}
        guard let data = worksheet.data,
              let keyRow = data.rows.first
        else { throw ParseError.data }
        let keysArray = keyRow.cells.dropFirst().compactMap { $0.stringValue(sharedStrings) }
        try keysArray.forEach {
            let xcodeLocalizationFilePath = xcodeLocalizationFilePath(for: $0)
            localizationsDictionary[$0] = try parseXcodeTranslations(fileURL: xcodeLocalizationFilePath)
        }
        let dataArray = data.rows.dropFirst()
        dataArray.forEach {
            parse(rowCells: $0.cells, keysArray: keysArray, sharedStrings: sharedStrings)
        }
    }

    /// Writes all parsed localizations.
    /// - Precondition: `parse()` should be called first.
    /// - Postcondition: After completing this method the parsed localizations will be written to the corresponding `.strings` files.
    /// - Throws: An error if there is an issue writing the localizations.
    func write() throws {
        try localizationsDictionary.forEach {
            let xcodeLocalizationFilePath = xcodeLocalizationFilePath(for: $0.key)
            delegate?.showAction("Writing to \(xcodeLocalizationFilePath.path.green()):")
            try xcodeLocalizationFilePath.eraseContent()
            let sortedLocalizations = localizationsDictionary[$0.key]?.sorted{ $0.key < $1.key } ?? []
            try sortedLocalizations.forEach({ (key: String, value: String) in
                let newLocalization = ("\"\(key)\" = \"\(value)\";\n")
                try newLocalization.write(to: xcodeLocalizationFilePath)
            })
        }
    }

    // MARK: Private Methods
    
    /// Generates the file path for Xcode localization based on the given key.
    /// - Parameter languageKey: The key used to generate the file path.
    /// - Returns: The file URL for the Xcode localization file.
    private func xcodeLocalizationFilePath(for languageKey: String) -> URL {
        URL(fileURLWithPath: "\(xcodeLocalizationMainPath)/\(languageKey)/\(localizationResourceName)")
    }
    
    /// Parses the row cells and updates the `xcodeLocalizations` dictionary.
    /// - Parameters:
    ///   - rowCells: The cells of the row containing localization values.
    ///   - keysArray: An array of keys corresponding to the columns in the worksheet.
    ///   - sharedStrings: The shared strings used for cell values.
    private func parse(rowCells: [Cell], keysArray: [String], sharedStrings: SharedStrings) {
        guard let key = rowCells.first?.stringValue(sharedStrings) else { return }
        for (index, cell) in rowCells.dropFirst().enumerated() {
            if let value = cell.stringValue(sharedStrings) {
                localizationsDictionary[keysArray[index]]?[key] = value
            }
        }
    }
    
    /// Parses Xcode localization file and returns the translations as a dictionary.
    /// - Parameter fileURL: The URL of the Xcode localization file.
    /// - Returns: A dictionary containing the parsed translations.
    /// - Throws: An error if there is an issue reading the file.
    private func parseXcodeTranslations(fileURL: URL) throws -> [String: String] {
        let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
        var translations: [String: String] = [:]
        let pattern = #""([^"]+)"\s*=\s*"([^"]+)";"#
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: fileContent, options: [], range: NSRange(location: 0, length: fileContent.utf16.count))

        for match in matches {
            guard
                let keyRange = Range(match.range(at: 1), in: fileContent),
                let valueRange = Range(match.range(at: 2), in: fileContent)
            else { continue }
            let key = String(fileContent[keyRange])
            let value = String(fileContent[valueRange])
            translations[key] = value
        }
        
        return translations
    }

}
