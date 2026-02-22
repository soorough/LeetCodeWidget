import SwiftUI
import WidgetKit

struct HeatmapGridView: View {
    let grid: HeatmapGrid
    let weekCount: Int

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                // Draw background
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(HeatmapColors.background)
                )

                let cols = CGFloat(weekCount)
                let rows: CGFloat = 7

                // Equal padding on all sides, same as half the gap between cells
                let padding: CGFloat = 4
                let gridW = size.width - padding * 2
                let gridH = size.height - padding * 2

                let stepX = gridW / cols
                let stepY = gridH / rows
                let gapX = stepX * 0.15
                let gapY = stepY * 0.15
                let cellW = stepX - gapX
                let cellH = stepY - gapY
                let cr = min(cellW, cellH) * 0.2
                let cornerCR = min(cellW, cellH) * 0.55

                let visible = min(weekCount, grid.weeks.count)
                let lastCol = visible - 1
                for wk in 0..<visible {
                    let week = grid.weeks[wk]
                    for d in 0..<7 {
                        // nil = future day, don't draw
                        guard d < week.count, let day = week[d] else { continue }

                        let x = padding + CGFloat(wk) * stepX + gapX / 2
                        let y = padding + CGFloat(d) * stepY + gapY / 2
                        let rect = CGRect(x: x, y: y, width: cellW, height: cellH)

                        let isCorner = (wk == 0 || wk == lastCol) && (d == 0 || d == 6)
                        let path: Path
                        if isCorner {
                            path = Path(roundedRect: rect, cornerRadii: RectangleCornerRadii(
                                topLeading: (wk == 0 && d == 0) ? cornerCR : cr,
                                bottomLeading: (wk == 0 && d == 6) ? cornerCR : cr,
                                bottomTrailing: (wk == lastCol && d == 6) ? cornerCR : cr,
                                topTrailing: (wk == lastCol && d == 0) ? cornerCR : cr
                            ))
                        } else {
                            path = Path(roundedRect: rect, cornerRadius: cr)
                        }

                        context.fill(path, with: .color(day.intensity.color))
                    }
                }
            }
        }
        .clipShape(ContainerRelativeShape())
    }
}
