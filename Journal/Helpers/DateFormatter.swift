//
//  DateFormatter.swift
//  Journal
//
//  Created by Kerby Jean on 4/30/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import Foundation

protocol DateFormatterType {
    func string(from date: Date) -> String
}

class CachedDateFormattingHelper {
    
    // MARK: - Shared
    
    static let shared = CachedDateFormattingHelper()
    
    // MARK: - Queue
    
    let cachedDateFormattersQueue = DispatchQueue(label: "com.boles.date.formatter.queue")
    
    // MARK: - Cached Formatters
    
    private var cachedDateFormatters = [String: DateFormatterType]()
    
    private func cachedDateFormatter(withFormat format: String) -> DateFormatterType {
        cachedDateFormattersQueue.sync {
            let key = format
            if let cachedFormatter = cachedDateFormatters[key] {
                return cachedFormatter
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = format
            
            cachedDateFormatters[key] = dateFormatter
            
            return dateFormatter
        }
    }
    
    // MARK: Today date
    
    func formatTodayDate() -> String {
        let dateFormatter = cachedDateFormatter(withFormat: "MMMM/dd/yy")
        let formattedDate = dateFormatter.string(from: Date())
        return formattedDate
    }
}

extension DateFormatter: DateFormatterType { }
