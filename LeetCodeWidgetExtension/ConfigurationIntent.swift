import AppIntents
import WidgetKit

struct LeetCodeWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "LeetCode Heatmap"
    static var description: IntentDescription = "Shows your LeetCode submission heatmap"

    @Parameter(title: "Username", default: "soorough")
    var username: String
}
