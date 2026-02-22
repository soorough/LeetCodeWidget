import Foundation

enum DateHelpers {
    private static var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1 // Sunday
        return cal
    }

    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func date(from timestamp: TimeInterval) -> Date {
        startOfDay(Date(timeIntervalSince1970: timestamp))
    }

    static func daysBetween(_ from: Date, _ to: Date) -> Int {
        calendar.dateComponents([.day], from: startOfDay(from), to: startOfDay(to)).day ?? 0
    }

    static func weekday(of date: Date) -> Int {
        // 0=Sunday, 1=Monday, ..., 6=Saturday
        (calendar.component(.weekday, from: date) + 6) % 7
        // Calendar .weekday: 1=Sun, 2=Mon... → we want 0=Sun
    }

    static func weekdayIndex(of date: Date) -> Int {
        calendar.component(.weekday, from: date) - 1 // 0=Sun, 1=Mon, ..., 6=Sat
    }

    static func addDays(_ days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date
    }

    static func month(of date: Date) -> Int {
        calendar.component(.month, from: date)
    }

    static func year(of date: Date) -> Int {
        calendar.component(.year, from: date)
    }

    static func startOfWeek(containing date: Date) -> Date {
        let day = startOfDay(date)
        let weekdayIdx = weekdayIndex(of: day) // 0=Sun
        return addDays(-weekdayIdx, to: day)
    }

    static let shortMonthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
}
