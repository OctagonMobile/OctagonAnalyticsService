//
//  DateParser.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 16/08/2020.
//

import Foundation

class DateParser {
    
    static var shared = DateParser()
    
    func parse(_ dateString: String) -> Date? {
        
        let contentAddition = dateString.components(separatedBy: "+")
        let contentSubstraction = dateString.components(separatedBy: "-")

        if contentAddition.count > 1 {
            return parseDateContent(contentAddition, shouldAdd: true)
        } else if contentSubstraction.count > 1 {
            return parseDateContent(contentSubstraction, shouldAdd: false)
        } else {
            return parseDateString(dateString)
        }
    }
    
    private func parseDateContent(_ content: [String], shouldAdd: Bool) -> Date? {
                
        guard let firstPart = content.first, let lastPart = content.last else { return nil }

        let number =  lastPart.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let type =  lastPart.components(separatedBy: CharacterSet.decimalDigits).joined()
        
        if let date = parseDateString(firstPart), let value = Int(number) {
            
            let numberToAdd = shouldAdd ? value : -(value)
            return Calendar.current.date(byAdding: getMappedCalendarComponantTypeFor(type), value: numberToAdd, to: date)
        }
        return nil
    }
    
    private func parseDateString(_ dateStr: String) -> Date? {
        
        if dateStr == "now" {
            return Date()
        }
        
        return nil
    }
    
    private func getMappedCalendarComponantTypeFor(_ type: String) -> Calendar.Component {
        switch type {
        case "y": return .year
        case "M": return .month
        case "w": return .weekOfMonth
        case "d": return .day
        case "H": return .hour
        case "m": return .minute
        case "s": return .second
        default:
            return .year
        }
    }
}

extension String {
    var westernArabicNumeralsOnly: String {
        let pattern = UnicodeScalar("0")..."9"
        return String(unicodeScalars
            .compactMap { pattern ~= $0 ? Character($0) : nil })
    }
}
