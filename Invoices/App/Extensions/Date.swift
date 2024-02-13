//
//  Date.swift
//  Invoices
//
//  Created by Cristian Baluta on 08.09.2021.
//

import Foundation

extension Date {
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth (lastWorkingDay: Bool = true) -> Date {
        let i = -1
        var date = Calendar.current.date(byAdding: DateComponents(month: 1, day: i), to: self.startOfMonth())!
        if lastWorkingDay {
            if date.dayNumberOfWeek() == 1 || date.dayNumberOfWeek() > 6 {// Sun or Sat
                date = Calendar.current.date(byAdding: DateComponents(day: i), to: date)!
            }
            if date.dayNumberOfWeek() == 1 || date.dayNumberOfWeek() > 6 {// Sun or Sat
                date = Calendar.current.date(byAdding: DateComponents(day: i), to: date)!
            }
        }
        return date
    }
    
    func nextMonth() -> Date {
        Calendar.current.date(byAdding: DateComponents(month: 1), to: self)!
    }
    
    func dayNumberOfWeek() -> Int {
        return Calendar.current.dateComponents([.weekday], from: self).weekday ?? 0
    }
    
    var yyyyMMdd: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: self)
    }

    var yyyyMMdd_dashes: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }

    var mediumDate: String {
        let comp = Calendar.current.dateComponents([.year, .month, .day], from: self)
        var month = ""
        switch comp.month {
            case 1: month = "Ian"
            case 2: month = "Feb"
            case 3: month = "Mar"
            case 4: month = "Apr"
            case 5: month = "Mai"
            case 6: month = "Iun"
            case 7: month = "Iul"
            case 8: month = "Aug"
            case 9: month = "Sept"
            case 10: month = "Oct"
            case 11: month = "Nov"
            case 12: month = "Dec"
            default: break
        }
        return "\(comp.day ?? 0)-\(month)-\(comp.year ?? 0)"
    }
    
    var fullMonthName: String {
        let comp = Calendar.current.dateComponents([.month], from: self)
        switch comp.month {
            case 1: return "Ianuarie"
            case 2: return "Februarie"
            case 3: return "Martie"
            case 4: return "Aprilie"
            case 5: return "Mai"
            case 6: return "Iunie"
            case 7: return "Iulie"
            case 8: return "August"
            case 9: return "Septembrie"
            case 10: return "Octombrie"
            case 11: return "Noiembrie"
            case 12: return "Decembrie"
            default: return ""
        }
    }
    
    var year: Int {
        let comp = Calendar.current.dateComponents([.year], from: self)
        return comp.year ?? 0
    }
    
    init?(yyyyMMdd: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "yyyy.MM.dd"
        if let date = dateFormatter.date(from: yyyyMMdd) {
            self = date
        } else {
            return nil
        }
    }
}
