import SwiftUI
import WidgetKit

struct HeatmapGridView: View {
    let grid: HeatmapGrid
    let weekCount: Int

    var body: some View {
        GeometryReader { geo in
            let cols = CGFloat(weekCount)
            let rows: CGFloat = 7
            let gap: CGFloat = 0.2
            let stepX = geo.size.width / cols
            let stepY = geo.size.height / rows
            let cellW = stepX * (1.0 - gap)
            let cellH = stepY * (1.0 - gap)
            let cr = min(cellW, cellH) * 0.18

            Canvas { context, size in
                // Draw background to fill entire widget
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(HeatmapColors.background)
                )

                let visible = min(weekCount, grid.weeks.count)
                let lastCol = visible - 1
                for wk in 0..<visible {
                    let week = grid.weeks[wk]
                    for d in 0..<7 {
                        let x = CGFloat(wk) * stepX + (stepX - cellW) / 2
                        let y = CGFloat(d) * stepY + (stepY - cellH) / 2
                        var rect = CGRect(x: x, y: y, width: cellW, height: cellH)

                        // Extend edge cells to the widget boundary so
                        // ContainerRelativeShape clips the corners naturally
                        if wk == 0 {
                            rect.size.width += rect.origin.x
                            rect.origin.x = 0
                        }
                        if wk == lastCol {
                            rect.size.width = size.width - rect.origin.x
                        }
                        if d == 0 {
                            rect.size.height += rect.origin.y
                            rect.origin.y = 0
                        }
                        if d == 6 {
                            rect.size.height = size.height - rect.origin.y
                        }

                        // nil = future day, don't draw (just background)
                        guard d < week.count, let day = week[d] else { continue }
                        let path = Path(roundedRect: rect, cornerRadius: cr)
                        context.fill(path, with: .color(day.intensity.color))
                    }
                }
            }
        }
        .clipShape(ContainerRelativeShape())
    }
}
