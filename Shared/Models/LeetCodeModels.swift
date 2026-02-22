import Foundation
import SwiftUI

// MARK: - GraphQL Response Models

struct GraphQLResponse: Decodable {
    let data: GraphQLData
}

struct GraphQLData: Decodable {
    let matchedUser: MatchedUser
}

struct MatchedUser: Decodable {
    let userCalendar: UserCalendar
}

struct UserCalendar: Decodable {
    let streak: Int
    let totalActiveDays: Int
    let submissionCalendar: String
}

// MARK: - Processed Data

struct LeetCodeCalendarData {
    let username: String
    let streak: Int
    let totalActiveDays: Int
    let submissions: [Date: Int] // date → submission count
}

// MARK: - Heatmap Types

enum HeatmapIntensity: Int, CaseIterable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    case extreme = 4

    static func from(count: Int) -> HeatmapIntensity {
        switch count {
        case 0: return .none
        case 1...2: return .low
        case 3...5: return .medium
        case 6...9: return .high
        default: return .extreme
        }
    }

    var color: Color {
        switch self {
        case .none: return HeatmapColors.none
        case .low: return HeatmapColors.low
        case .medium: return HeatmapColors.medium
        case .high: return HeatmapColors.high
        case .extreme: return HeatmapColors.extreme
        }
    }
}

struct DaySubmission {
    let date: Date
    let count: Int

    var intensity: HeatmapIntensity {
        HeatmapIntensity.from(count: count)
    }
}
