import SwiftUI

enum AppConstants {
    static let appGroupID = "group.com.souravh.leetcodewidget"
    static let usernameKey = "leetcode_username"
    static let defaultUsername = "soorough"
    static let refreshInterval: TimeInterval = 30 * 60
    static let leetcodeGraphQLURL = "https://leetcode.com/graphql"
}

enum HeatmapColors {
    static let background = Color(red: 0x12/255, green: 0x12/255, blue: 0x14/255)
    static let none = Color(red: 0x1a/255, green: 0x1e/255, blue: 0x24/255)
    static let low = Color(red: 0x00/255, green: 0x6d/255, blue: 0x2c/255)
    static let medium = Color(red: 0x26/255, green: 0xa6/255, blue: 0x41/255)
    static let high = Color(red: 0x3d/255, green: 0xcc/255, blue: 0x70/255)
    static let extreme = Color(red: 0x39/255, green: 0xf0/255, blue: 0x7d/255)
}

enum HeatmapConfig {
    static let cornerRadius: CGFloat = 3
    static let mediumWeekCount = 16
    static let largeWeekCount = 17
}
