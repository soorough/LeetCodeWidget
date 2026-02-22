import Foundation

actor LeetCodeService {
    static let shared = LeetCodeService()

    private let graphqlURL = URL(string: AppConstants.leetcodeGraphQLURL)!

    private let query = """
    query userProfileCalendar($username: String!, $year: Int) {
        matchedUser(username: $username) {
            userCalendar(year: $year) {
                streak
                totalActiveDays
                submissionCalendar
            }
        }
    }
    """

    func fetchCalendarData(username: String, year: Int? = nil) async throws -> LeetCodeCalendarData {
        let body: [String: Any] = [
            "query": query,
            "variables": year.map { ["username": username, "year": $0] as [String: Any] }
                ?? ["username": username]
        ]

        var request = URLRequest(url: graphqlURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LeetCodeError.invalidResponse
        }

        let graphqlResponse = try JSONDecoder().decode(GraphQLResponse.self, from: data)
        let calendar = graphqlResponse.data.matchedUser.userCalendar

        // Two-stage parse: submissionCalendar is a JSON string like {"1234567890": 3, ...}
        let submissions = try parseSubmissionCalendar(calendar.submissionCalendar)

        return LeetCodeCalendarData(
            username: username,
            streak: calendar.streak,
            totalActiveDays: calendar.totalActiveDays,
            submissions: submissions
        )
    }

    func fetchFullYearData(username: String) async throws -> LeetCodeCalendarData {
        let now = Date()
        let currentYear = DateHelpers.year(of: now)

        // Always fetch current year
        let currentData = try await fetchCalendarData(username: username, year: currentYear)

        // Check if the 52-week window spans into the previous year
        let startOfWindow = DateHelpers.addDays(-364, to: now)
        let startYear = DateHelpers.year(of: startOfWindow)

        if startYear < currentYear {
            // Also fetch previous year and merge
            let previousData = try await fetchCalendarData(username: username, year: startYear)
            var merged = previousData.submissions
            for (date, count) in currentData.submissions {
                merged[date] = count
            }
            return LeetCodeCalendarData(
                username: username,
                streak: currentData.streak,
                totalActiveDays: currentData.totalActiveDays,
                submissions: merged
            )
        }

        return currentData
    }

    private let dailyQuery = """
    query questionOfToday {
        activeDailyCodingChallengeQuestion {
            link
            question {
                title
                titleSlug
            }
        }
    }
    """

    func fetchDailyProblemURL() async -> URL {
        let fallback = URL(string: "https://leetcode.com/problemset/")!
        do {
            let body: [String: Any] = ["query": dailyQuery, "variables": [:] as [String: Any]]
            var request = URLRequest(url: graphqlURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let challenge = dataDict["activeDailyCodingChallengeQuestion"] as? [String: Any],
               let link = challenge["link"] as? String {
                return URL(string: "https://leetcode.com\(link)") ?? fallback
            }
        } catch {}
        return fallback
    }

    private func parseSubmissionCalendar(_ calendarString: String) throws -> [Date: Int] {
        guard let jsonData = calendarString.data(using: .utf8) else {
            throw LeetCodeError.parseError
        }

        guard let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Int] else {
            throw LeetCodeError.parseError
        }

        var submissions: [Date: Int] = [:]
        for (timestampStr, count) in dict {
            if let timestamp = TimeInterval(timestampStr) {
                let date = DateHelpers.date(from: timestamp)
                submissions[date] = count
            }
        }
        return submissions
    }
}

enum LeetCodeError: Error, LocalizedError {
    case invalidResponse
    case parseError
    case noUsername

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response from LeetCode API"
        case .parseError: return "Failed to parse submission data"
        case .noUsername: return "No username configured"
        }
    }
}
