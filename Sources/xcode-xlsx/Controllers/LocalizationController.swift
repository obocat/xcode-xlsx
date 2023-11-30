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
    private var createDictionary: [String: [String: String]] = [:]
    private var updateDictionary: [String: [String: String]] = [:]
    
    enum ParseError: Error, LocalizedError {
        case sharedStrings
        case dataXLSX

        public var errorDescription: String? {
            switch self {
            case .sharedStrings:
                return "XLSX shared strings not found"
            case .dataXLSX:
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
        else { throw ParseError.dataXLSX }
        let keysArray = keyRow.cells.dropFirst().compactMap { $0.stringValue(sharedStrings) }
        let dataArray = data.rows.dropFirst()
        try keysArray.forEach {
            let xcodeLocalizationFilePath = xcodeLocalizationFilePath(for: $0)
            createDictionary[$0] = [:]
            updateDictionary[$0] = try parseXcodeTranslations(fileURL: xcodeLocalizationFilePath)
        }
        try dataArray.forEach {
            try populateDictionariesWithXls(rowCells: $0.cells, keysArray: keysArray, sharedStrings: sharedStrings)
        }
    }

    /// Writes all parsed localizations.
    /// - Precondition: `parse()` should be called first.
    /// - Postcondition: After completing this method the parsed localizations will be written to the corresponding `.strings` files.
    /// - Throws: An error if there is an issue writing the localizations.
    func write() throws {
        try updateDictionary.forEach { (language, translations) in
            let xcodeLocalizationFilePath = xcodeLocalizationFilePath(for: language)
            delegate?.showAction("Writing to \(xcodeLocalizationFilePath.path.green()):")
            var originalContent = try String(contentsOf: xcodeLocalizationFilePath)

            translations.forEach { (key, value) in
                let regexPattern = "\"\(key)\"\\s*=\\s*\"([^\"]*)\";"
                let replacement = "\"\(key)\" = \"\(value)\";"
                originalContent = originalContent.replacingOccurrences(
                    of: regexPattern,
                    with: replacement,
                    options: .regularExpression
                )
            }

            createDictionary[language]?.forEach({ (key, value) in
                let newLocalizationEntry = "\"\(key)\" = \"\(value)\";\n\n"
                originalContent.append(newLocalizationEntry)
            })
            
            try originalContent.write(to: xcodeLocalizationFilePath, atomically: true, encoding: .utf8)
        }
    }

    // MARK: Private Methods
    
    /// Generates the file path for Xcode localization based on the given key.
    /// - Parameter languageKey: The key used to generate the file path.
    /// - Returns: The file URL for the Xcode localization file.
    private func xcodeLocalizationFilePath(for languageKey: String) -> URL {
        URL(fileURLWithPath: "\(xcodeLocalizationMainPath)/\(languageKey)/\(localizationResourceName)")
    }
    
    /// Parses the row cells and updates the `createDictionary` and `updateDictionary` dictionaries respectively.
    /// - Parameters:
    ///   - rowCells: The cells of the row containing localization values.
    ///   - keysArray: An array of keys corresponding to the columns in the worksheet.
    ///   - sharedStrings: The shared strings used for cell values.
    private func populateDictionariesWithXls(rowCells: [Cell], keysArray: [String], sharedStrings: SharedStrings) throws {
        guard let key = rowCells.first?.stringValue(sharedStrings) else { throw ParseError.dataXLSX }
        for (index, cell) in rowCells.dropFirst().enumerated() {
            if let value = cell.stringValue(sharedStrings) {
                if updateDictionary[keysArray[index]]?[key] == nil {
                    createDictionary[keysArray[index]]?[key] = value
                } else {
                    updateDictionary[keysArray[index]]?[key] = value
                }
            }
        }
    }
    
    /// Parses Xcode localization file and returns the translations as a dictionary.
    /// - Parameter fileURL: The URL of the Xcode localization file.
    /// - Returns: A dictionary containing the parsed translations.
    /// - Throws: An error if there is an issue reading the file.
    private func parseXcodeTranslations(fileURL: URL) throws -> [String: String] {
        let data = try Data(contentsOf: fileURL)
        let decoder = PropertyListDecoder()
        return try decoder.decode([String: String].self, from: data)
    }

}
