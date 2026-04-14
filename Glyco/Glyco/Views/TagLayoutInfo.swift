//
//  TagLayoutEngine.swift
//  Glyco
//
//  Pure layout logic: given a set of tags for a day, compute
//  lane assignments and text-nudge offsets so nothing overlaps.
//

import SwiftUI
import CoreData

// Everything DayView needs to render one tag.
struct TagLayoutInfo {
    let tag: TagEntry

    // Time geometry
    let topY: CGFloat        // top of the block in the timeline
    let blockHeight: CGFloat // height of the block

    // Column splitting
    let lane: Int            // 0-based lane index
    let laneCount: Int       // total lanes in this overlap group

    // Text nudge: how far down inside the block to push the label
    // so it doesn't collide with the label of the tag above it in
    // the same lane.
    let textOffsetY: CGFloat
}

enum TagLayoutEngine {

    // Approximate line heights for the label stack:
    //   title  (caption bold)  ≈ 14 pt
    //   detail (caption2)      ≈ 12 pt
    //   duration (caption2)    ≈ 12 pt
    //   padding top            =   4 pt
    // We use 44 pt as a safe "minimum readable label height".
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

        // 1. Clip every tag to this day, drop those not visible.
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

        // 2. Sort by start time (then longer duration first for stable lanes).
        clipped.sort {
            if $0.start != $1.start { return $0.start < $1.start }
            return $0.end > $1.end
        }

        // 3. Assign lanes using a greedy interval-graph colouring.
        //    Each "lane" tracks the latest end time currently occupying it.
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

        // 4. For each tag, determine how many lanes its overlap group needs.
        //    An overlap group is the maximal set of tags that all share at least
        //    one common moment. We approximate this by looking at how many lanes
        //    are active at the tag's start time.
        func laneCountAt(start: Date, end: Date) -> Int {
            var count = 0
            for other in clipped {
                if other.start < end && other.end > start { count += 1 }
            }
            return max(count, 1)
        }

        // 5. Within each lane, nudge label text down so it doesn't collide
        //    with the label of the previous tag in the same lane.
        //    We track the lowest y at which a label has ended, per lane.
        var laneLabelBottom: [Int: CGFloat] = [:]

        var results: [TagLayoutInfo] = []

        for i in clipped.indices {
            let c    = clipped[i]
            let lane = laneAssignments[i]
            let laneCount = laneCountAt(start: c.start, end: c.end)

            let labelTopIdeal = c.topY + blockPadding
            let previousBottom = laneLabelBottom[lane] ?? 0

            // If the ideal label position is below the previous label's bottom,
            // no nudge needed. Otherwise push it down just enough.
            let nudge = max(0, previousBottom - labelTopIdeal)
            let textOffsetY = nudge

            // Update the bottom of the label region for this lane.
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