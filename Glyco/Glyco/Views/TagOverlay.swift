//
//  TagOverlay.swift
//  Glyco
//

import SwiftUI

struct TagOverlay: View {

    let info: TagLayoutInfo
    let width: CGFloat    // pre-computed lane width
    let xOffset: CGFloat  // pre-computed x position (from GeometryReader's left edge)

    var body: some View {
        let tag = info.tag

        ZStack(alignment: .topLeading) {
            // Background block — full height
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: tag.tag?.wrappedColorHex ?? "#CCCCCC").opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color(hex: tag.tag?.wrappedColorHex ?? "#CCCCCC").opacity(0.45), lineWidth: 1)
                )

            // Label — nudged down if it would collide with the tag above
            VStack(alignment: .leading, spacing: 2) {
                Text(tag.tag?.wrappedTitle ?? "Untitled")
                    .font(.caption)
                    .bold()
                    .lineLimit(2)

                if !tag.wrappedDetail.isEmpty {
                    Text(tag.wrappedDetail)
                        .font(.caption2)
                        .lineLimit(1)
                }

                Text(durationLabel)
                    .font(.caption2)
                    .opacity(0.7)
            }
            .padding(.horizontal, 5)
            .padding(.top, 4 + info.textOffsetY)  // nudge applied here
            .padding(.bottom, 4)
        }
        .frame(width: width, height: info.blockHeight)
        .offset(x: xOffset, y: info.topY)
    }

    // MARK: - Helpers

    private var durationLabel: String {
        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: info.tag.wrappedStart,
            to: info.tag.wrappedEnd
        )
        let h = components.hour   ?? 0
        let m = components.minute ?? 0
        if h == 0 { return "\(m)m" }
        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }
}
