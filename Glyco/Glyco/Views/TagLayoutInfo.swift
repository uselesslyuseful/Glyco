//
//  TagLayoutInfo.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-04-13.
//

import SwiftUI
import CoreData

struct TagLayoutInfo {
    let tag: TagEntry
    
    let topY: CGFloat        // top of the block in the timeline
    let blockHeight: CGFloat // height of the block

    let lane: Int            // 0-based lane index
    let laneCount: Int       // total lanes in this overlap group

    let textOffsetY: CGFloat
}

enum TagLayoutEngine {

    private static let labelHeight: CGFloat = 44
    private static let blockPadding: CGFloat = 4

    static func compute(
        tags: [TagEntry],
        day: Date,
        hourHeight: CGFloat
    ) -> [TagLayoutInfo] {

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: day)
        let endOfDay   = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        struct Clipped {
            let tag: TagEntry
            let start: Date
            let end: Date
            var topY: CGFloat
            var blockHeight: CGFloat
        }

        var clipped: [Clipped] = tags.compactMap { tag in
            let s = max(tag.wrappedStart, startOfDay)
            let e = min(tag.wrappedEnd,   endOfDay)
            guard e > s else { return nil }

            let startMin = calendar.dateComponents([.minute], from: startOfDay, to: s).minute ?? 0
            let endMin   = calendar.dateComponents([.minute], from: startOfDay, to: e).minute ?? 0

            let topY   = CGFloat(startMin) / 60.0 * hourHeight
            let height = max(CGFloat(endMin - startMin) / 60.0 * hourHeight, 24)

            return Clipped(tag: tag, start: s, end: e, topY: topY, blockHeight: height)
        }

        clipped.sort {
            if $0.start != $1.start { return $0.start < $1.start }
            return $0.end > $1.end
        }

        var laneEndTimes: [Date] = []
        var laneAssignments: [Int] = Array(repeating: 0, count: clipped.count)

        for i in clipped.indices {
            // Find the first lane whose last occupant has already ended.
            if let freeLane = laneEndTimes.indices.first(where: { laneEndTimes[$0] <= clipped[i].start }) {
                laneAssignments[i] = freeLane
                laneEndTimes[freeLane] = clipped[i].end
            } else {
                laneAssignments[i] = laneEndTimes.count
                laneEndTimes.append(clipped[i].end)
            }
        }

        func laneCountAt(start: Date, end: Date) -> Int {
            var count = 0
            for other in clipped {
                if other.start < end && other.end > start { count += 1 }
            }
            return max(count, 1)
        }

        var laneLabelBottom: [Int: CGFloat] = [:]

        var results: [TagLayoutInfo] = []

        for i in clipped.indices {
            let c    = clipped[i]
            let lane = laneAssignments[i]
            let laneCount = laneCountAt(start: c.start, end: c.end)

            let labelTopIdeal = c.topY + blockPadding
            let previousBottom = laneLabelBottom[lane] ?? 0

            let nudge = max(0, previousBottom - labelTopIdeal)
            let textOffsetY = nudge

            let labelBottom = labelTopIdeal + nudge + labelHeight
            // Only update if this label's bottom is lower than what's there.
            laneLabelBottom[lane] = max(laneLabelBottom[lane] ?? 0, labelBottom)

            results.append(TagLayoutInfo(
                tag: c.tag,
                topY: c.topY,
                blockHeight: c.blockHeight,
                lane: lane,
                laneCount: laneCount,
                textOffsetY: textOffsetY
            ))
        }

        return results
    }
}
