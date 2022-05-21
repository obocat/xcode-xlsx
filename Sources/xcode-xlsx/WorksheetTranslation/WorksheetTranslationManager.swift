//
//  WorksheetTranslationManager.swift
//  xcode-xlsx
//
//  Created by Daniel Toranzo Pérez on 21/5/22.
//

import Foundation
import CoreXLSX

enum WorksheetTranslationManagerError: Error, LocalizedError {
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

class WorksheetTranslationManager {
    let name: String
    let file: XLSXFile
    let path: String
    let worksheet: Worksheet
    let sharedStrings: SharedStrings
    let xcodeLocalizationPath: String
    
    init(name: String, file: XLSXFile, at: String, xcodeLocalizationPath: String) throws {
        self.name = name
        self.file = file
        self.path = at
        self.worksheet = try file.parseWorksheet(at: self.path)
        guard let sharedStringsTemp = try file.parseSharedStrings() else { throw WorksheetTranslationManagerError.sharedStrings }
        self.sharedStrings = sharedStringsTemp
        self.xcodeLocalizationPath = xcodeLocalizationPath
    }
    
    func insertTranslations() throws {
        guard let data = worksheet.data else { throw WorksheetTranslationManagerError.data }
        guard let keyRow = data.rows.first else { return }
        let keysArray = keyRow.cells.dropFirst().compactMap { $0.stringValue(sharedStrings) }
        let dataArray = data.rows.dropFirst()
        guard keysArray.count == dataArray.count else { throw WorksheetTranslationManagerError.data }
        for row in dataArray {
            insertTranslations(rowCells: row.cells, keysArray: keysArray)
        }
    }

    private func insertTranslations(rowCells: [Cell], keysArray: [String]) {
        guard let key = rowCells.first?.stringValue(sharedStrings) else { return }
        for (index, cell) in rowCells.dropFirst().enumerated() {
            if let value = cell.stringValue(sharedStrings) {
                let localization = Localization(key: key, value: value)
                let value = localization.description
                let path = URL(fileURLWithPath: "\(xcodeLocalizationPath)/\(keysArray[index])/\(name)")
                print("Writing to \(path.path.terminalColor(color: .green)):\n\(value)")
                do {
                    try value.write(to: path)
                } catch {
                    let failed = "Failed".terminalColor(color: .red).appending("\n")
                    print(failed)
                }
            }
        }
    }
}

class Localization: CustomStringConvertible {
    private let key: String
    private let value: String
    
    var description: String {
        ("\"\(key)\" = \"\(value)\";").appendBreakToBothEnds
    }
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}
