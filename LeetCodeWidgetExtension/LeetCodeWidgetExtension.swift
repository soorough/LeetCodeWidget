import WidgetKit
import SwiftUI

struct LeetCodeEntry: TimelineEntry {
    let date: Date
    let calendarData: LeetCodeCalendarData?
    let heatmapGrid: HeatmapGrid?
    let dailyProblemURL: URL
    let configuration: LeetCodeWidgetIntent
    let isPlaceholder: Bool

    static let fallbackURL = URL(string: "https://leetcode.com/problemset/")!

    static func placeholder() -> LeetCodeEntry {
        LeetCodeEntry(
            date: Date(),
            calendarData: nil,
            heatmapGrid: nil,
            dailyProblemURL: fallbackURL,
            configuration: LeetCodeWidgetIntent(),
            isPlaceholder: true
        )
    }
}

struct LeetCodeTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = LeetCodeEntry
    typealias Intent = LeetCodeWidgetIntent

    func placeholder(in context: Context) -> LeetCodeEntry {
        .placeholder()
    }

    func snapshot(for configuration: LeetCodeWidgetIntent, in context: Context) async -> LeetCodeEntry {
        if context.isPreview {
            return .placeholder()
        }
        return await fetchEntry(for: configuration, in: context)
    }

    func timeline(for configuration: LeetCodeWidgetIntent, in context: Context) async -> Timeline<LeetCodeEntry> {
        let entry = await fetchEntry(for: configuration, in: context)
        let refreshDate = Date().addingTimeInterval(AppConstants.refreshInterval)
        return Timeline(entries: [entry], policy: .after(refreshDate))
    }

    private func fetchEntry(for configuration: LeetCodeWidgetIntent, in context: Context) async -> LeetCodeEntry {
        let username = resolveUsername(from: configuration)
        let dailyURL = await LeetCodeService.shared.fetchDailyProblemURL()

        guard !username.isEmpty else {
            return LeetCodeEntry(
                date: Date(),
                calendarData: nil,
                heatmapGrid: nil,
                dailyProblemURL: dailyURL,
                configuration: configuration,
                isPlaceholder: false
            )
        }

        do {
            let calendarData = try await LeetCodeService.shared.fetchFullYearData(username: username)
            let weekCount = context.family == .systemLarge
                ? HeatmapConfig.largeWeekCount
                : HeatmapConfig.mediumWeekCount
            let grid = HeatmapGrid.build(from: calendarData.submissions, weekCount: weekCount)

            return LeetCodeEntry(
                date: Date(),
                calendarData: calendarData,
                heatmapGrid: grid,
                dailyProblemURL: dailyURL,
                configuration: configuration,
                isPlaceholder: false
            )
        } catch {
            return LeetCodeEntry(
                date: Date(),
                calendarData: nil,
                heatmapGrid: nil,
                dailyProblemURL: dailyURL,
                configuration: configuration,
                isPlaceholder: false
            )
        }
    }

    private func resolveUsername(from configuration: LeetCodeWidgetIntent) -> String {
        let intentUsername = configuration.username
        if !intentUsername.isEmpty {
            return intentUsername
        }
        return AppConstants.defaultUsername
    }
}

struct LeetCodeWidget: Widget {
    let kind = "LeetCodeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: LeetCodeWidgetIntent.self,
            provider: LeetCodeTimelineProvider()
        ) { entry in
            Color.clear
                .widgetURL(entry.dailyProblemURL)
                .containerBackground(for: .widget) {
                    LeetCodeWidgetEntryView(entry: entry)
                }
        }
        .configurationDisplayName("LeetCode Heatmap")
        .description("Shows your LeetCode submission heatmap")
        .supportedFamilies([.systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

@main
struct LeetCodeWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        LeetCodeWidget()
    }
}
