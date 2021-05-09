//
//  Extenson.swift
//  ProjectManager
//
//  Created by 강인희 on 2021/03/23.
//

import Foundation

// MARK: - DateFormating

extension DateFormatter {
    func convertDateToString(date: Date) -> String {
        let currentLocale = Locale.current.collatorIdentifier ?? "ko_KR"
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: currentLocale)
        formatter.dateFormat = "yyyy.MM.dd"
        
        return formatter.string(from: date)
    }
}

// MARK: - LocalizedString

extension String  {
    var localized: String  {
        return NSLocalizedString(self, comment: "")
    }
}

