import SwiftUI
import WidgetKit

struct LeetCodeWidgetEntryView: View {
    let entry: LeetCodeEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        if let grid = entry.heatmapGrid {
            HeatmapGridView(grid: grid, weekCount: family == .systemLarge
                ? HeatmapConfig.largeWeekCount
                : HeatmapConfig.mediumWeekCount)
        } else {
            HeatmapColors.background
        }
    }
}
