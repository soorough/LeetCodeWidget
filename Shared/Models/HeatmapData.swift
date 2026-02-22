import Foundation

struct MonthLabel {
    let name: String
    let weekIndex: Int
}

struct HeatmapGrid {
    let weeks: [[DaySubmission?]] // weeks[weekIndex][dayIndex(0=Sun..6=Sat)]
    let monthLabels: [MonthLabel]

    static func build(
        from submissions: [Date: Int],
        endDate: Date = Date(),
        weekCount: Int = HeatmapConfig.largeWeekCount
    ) -> HeatmapGrid {
        let today = DateHelpers.startOfDay(endDate)
        let endOfWeek = DateHelpers.startOfWeek(containing: today)
        let startDate = DateHelpers.addDays(-7 * (weekCount - 1), to: endOfWeek)

        var weeks: [[DaySubmission?]] = []
        var monthLabels: [MonthLabel] = []
        var lastMonth = -1

        for weekIdx in 0..<weekCount {
            let weekStart = DateHelpers.addDays(7 * weekIdx, to: startDate)
            var week: [DaySubmission?] = []

            for dayIdx in 0..<7 {
                let date = DateHelpers.addDays(dayIdx, to: weekStart)
                if date > today {
                    week.append(nil)
                } else {
                    let count = submissions[DateHelpers.startOfDay(date)] ?? 0
                    week.append(DaySubmission(date: date, count: count))
                }
            }
            weeks.append(week)

            // Track month labels at the first week of each month
            let firstDayOfWeek = weekStart
            let month = DateHelpers.month(of: firstDayOfWeek)
            if month != lastMonth {
                let name = DateHelpers.shortMonthNames[month - 1]
                monthLabels.append(MonthLabel(name: name, weekIndex: weekIdx))
                lastMonth = month
            }
        }

        return HeatmapGrid(weeks: weeks, monthLabels: monthLabels)
    }
}
