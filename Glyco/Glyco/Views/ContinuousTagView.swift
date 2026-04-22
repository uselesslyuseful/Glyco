
//
//  ContinuousTagView.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-04-13.
//

import SwiftUI

struct ContinuousTagView: View {

    let tag: TagEntry
    let hourHeight: CGFloat
    let selectedDate: Date

    @State private var showEdit = false

    var body: some View {

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)

        let startMin = minutes(from: startOfDay, to: tag.wrappedStart)
        let endMin = minutes(from: startOfDay, to: tag.wrappedEnd)

        let top = CGFloat(startMin) / 60 * hourHeight
        let height = max(CGFloat(endMin - startMin) / 60 * hourHeight, 20)

        return tagBody
            .frame(height: height, alignment: .top)
            .position(
                x: 180,   // fixed x lane (important for hit testing)
                y: top + height / 2
            )
            .onTapGesture(count: 2) {
                showEdit = true
            }
            .sheet(isPresented: $showEdit) {
                EditTagView(tag: tag)
            }
    }

    private var tagBody: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(tag.tag?.wrappedTitle ?? "Untitled")
                .font(.caption)
                .bold()

            if !tag.wrappedDetail.isEmpty {
                Text(tag.wrappedDetail)
                    .font(.caption2)
            }
        }
        .padding(6)
        .background(Color(hex: tag.tag?.wrappedColorHex ?? "#CCCCCC").opacity(0.45))
        .cornerRadius(8)
    }

    private func minutes(from start: Date, to end: Date) -> Int {
        Calendar.current.dateComponents([.minute], from: start, to: end).minute ?? 0
    }
}
