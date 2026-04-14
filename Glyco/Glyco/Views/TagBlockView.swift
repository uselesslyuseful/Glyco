
import SwiftUI

struct TagBlockView: View {
    let tag: TagEntry
    let hourHeight: CGFloat
    let selectedDate: Date

    var body: some View {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let (visibleStart, visibleEnd) = clampToDay(startOfDay: startOfDay, endOfDay: endOfDay)

        let startMinutes = minutesSince(startOfDay, to: visibleStart)
        let endMinutes = minutesSince(startOfDay, to: visibleEnd)

        let topOffset = CGFloat(startMinutes) / 60 * hourHeight
        let height = max(CGFloat(endMinutes - startMinutes) / 60 * hourHeight, 25)

        return VStack(alignment: .leading, spacing: 2) {

            Text(tag.wrappedTitle)
                .font(.caption)
                .bold()

            if !tag.wrappedDetail.isEmpty {
                Text(tag.wrappedDetail)
                    .font(.caption2)
            }

            // show duration only if fully inside day
            if calendar.isDate(tag.wrappedStart, inSameDayAs: tag.wrappedEnd) {
                Text(durationString())
                    .font(.caption2)
                    .opacity(0.7)
            } else {
                Text("continues…")
                    .font(.caption2)
                    .opacity(0.6)
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: tag.wrappedColorHex).opacity(0.6)) // 👈 semi-transparent
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.1))
        )
        .offset(x: 60, y: topOffset)
        .frame(height: height, alignment: .top)
        .padding(.trailing, 8)
    }

    // MARK: - CLAMP MULTI-DAY TAGS TO CURRENT DAY
    private func clampToDay(startOfDay: Date, endOfDay: Date) -> (Date, Date) {
        let start = max(tag.wrappedStart, startOfDay)
        let end = min(tag.wrappedEnd, endOfDay)
        return (start, end)
    }

    private func minutesSince(_ start: Date, to end: Date) -> Int {
        Calendar.current.dateComponents([.minute], from: start, to: end).minute ?? 0
    }

    private func durationString() -> String {
        let diff = Calendar.current.dateComponents([.hour, .minute],
                                                  from: tag.wrappedStart,
                                                  to: tag.wrappedEnd)
        return "\(diff.hour ?? 0)h \(diff.minute ?? 0)m"
    }
}
