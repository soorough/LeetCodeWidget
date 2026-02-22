import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var username: String = ""
    @State private var calendarData: LeetCodeCalendarData?
    @State private var heatmapGrid: HeatmapGrid?
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let defaults = UserDefaults.standard

    var body: some View {
        VStack(spacing: 20) {
            headerSection
            inputSection
            if isLoading {
                ProgressView("Fetching data...")
                    .padding()
            } else if let error = errorMessage {
                errorView(error)
            } else if let data = calendarData, let grid = heatmapGrid {
                statsSection(data: data)
                previewSection(grid: grid)
            }
            Spacer()
        }
        .padding(24)
        .background(HeatmapColors.background)
        .onAppear {
            username = defaults.string(forKey: AppConstants.usernameKey) ?? AppConstants.defaultUsername
            Task { await fetchData() }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("LeetCode Heatmap")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            Text("Desktop Widget")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private var inputSection: some View {
        HStack(spacing: 12) {
            TextField("LeetCode Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 200)

            Button(action: {
                saveAndRefresh()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                    Text("Save & Refresh")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(username.isEmpty || isLoading)
        }
    }

    private func statsSection(data: LeetCodeCalendarData) -> some View {
        HStack(spacing: 24) {
            statItem(icon: "flame.fill", iconColor: .orange, label: "Streak", value: "\(data.streak)")
            statItem(icon: "calendar", iconColor: .blue, label: "Active Days", value: "\(data.totalActiveDays)")
            statItem(icon: "number", iconColor: .green, label: "Total Submissions",
                     value: "\(data.submissions.values.reduce(0, +))")
        }
        .padding(.vertical, 8)
    }

    private func statItem(icon: String, iconColor: Color, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(value)
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private func previewSection(grid: HeatmapGrid) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Widget Preview")
                .font(.caption)
                .foregroundColor(.gray)

            HeatmapPreviewView(grid: grid)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(white: 0.1))
                )

            legendRow
        }
    }

    private var legendRow: some View {
        HStack(spacing: 3) {
            Spacer()
            Text("Less")
                .font(.system(size: 8))
                .foregroundColor(.gray)
            ForEach(HeatmapIntensity.allCases, id: \.rawValue) { intensity in
                RoundedRectangle(cornerRadius: 2)
                    .fill(intensity.color)
                    .frame(width: 10, height: 10)
            }
            Text("More")
                .font(.system(size: 8))
                .foregroundColor(.gray)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
            Button("Retry") { Task { await fetchData() } }
                .buttonStyle(.bordered)
        }
        .padding()
    }

    private func saveAndRefresh() {
        defaults.set(username, forKey: AppConstants.usernameKey)
        WidgetCenter.shared.reloadAllTimelines()
        Task { await fetchData() }
    }

    private func fetchData() async {
        guard !username.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            let data = try await LeetCodeService.shared.fetchFullYearData(username: username)
            let grid = HeatmapGrid.build(from: data.submissions, weekCount: HeatmapConfig.largeWeekCount)
            await MainActor.run {
                self.calendarData = data
                self.heatmapGrid = grid
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

// Simplified heatmap preview for the main app (uses SwiftUI views instead of Canvas for compatibility)
struct HeatmapPreviewView: View {
    let grid: HeatmapGrid
    private let cellSize: CGFloat = 6
    private let spacing: CGFloat = 2

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(0..<grid.weeks.count, id: \.self) { weekIdx in
                    VStack(spacing: spacing) {
                        ForEach(0..<7, id: \.self) { dayIdx in
                            if dayIdx < grid.weeks[weekIdx].count,
                               let day = grid.weeks[weekIdx][dayIdx] {
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(day.intensity.color)
                                    .frame(width: cellSize, height: cellSize)
                            } else {
                                Color.clear
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            }
        }
    }
}
