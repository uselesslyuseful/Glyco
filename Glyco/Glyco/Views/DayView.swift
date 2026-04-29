
//
//  DayView.swift
//  Glyco
//

import SwiftUI
import CoreData

struct DayView: View {
    @Binding var selectedDate: Date

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest var tags: FetchedResults<TagEntry>

    @State private var showAddTag = false
    @State private var tagToEdit: TagEntry? = nil

    private let hourHeight: CGFloat = 60
    private let labelWidth: CGFloat = 50
    private let lanePadding: CGFloat = 2
    let selectedTags: Set<Tag>

    init(selectedDate: Binding<Date>, selectedTags: Set<Tag>) {
        self._selectedDate = selectedDate
        self.selectedTags = selectedTags

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate.wrappedValue)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        _tags = FetchRequest<TagEntry>(
            sortDescriptors: [NSSortDescriptor(keyPath: \TagEntry.startDate, ascending: true)],
            predicate: NSPredicate(
                format: "startDate < %@ AND endDate > %@",
                endOfDay as NSDate,
                startOfDay as NSDate
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(selectedDate, style: .date)
                    .font(.headline)
                Spacer()
                Button { showAddTag = true } label: {
                    Image(systemName: "plus")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            ScrollView(.vertical) {
                ZStack(alignment: .topLeading) {

                    // 1. Hour grid (provides intrinsic height for the ZStack)
                    VStack(spacing: 0) {
                        ForEach(0..<24, id: \.self) { hour in
                            HStack(spacing: 0) {
                                Text(String(format: "%02d:00", hour))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: labelWidth, alignment: .leading)

                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: hourHeight)
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 0.5)
                                            .foregroundStyle(Color.gray.opacity(0.3)),
                                        alignment: .top
                                    )
                            }
                        }
                    }

                    // 2. Tag layer
                    GeometryReader { geo in
                        let columnWidth = geo.size.width - labelWidth
                        let visibleTags = tags.filter { entry in
                            guard let tag = entry.tag else { return false }

                            if tag.isSystem {
                                return selectedTags.contains(tag)
                            } else {
                                return true
                            }
                        }

                        let layouts = TagLayoutEngine.compute(
                            tags: Array(visibleTags),
                            day: selectedDate,
                            hourHeight: hourHeight
                        )

                        ForEach(layouts, id: \.tag.objectID) { info in
                            let laneWidth = (columnWidth - lanePadding * CGFloat(info.laneCount - 1))
                                            / CGFloat(info.laneCount)
                            let laneX     = labelWidth
                                            + CGFloat(info.lane) * (laneWidth + lanePadding)

                            TagOverlay(
                                info: info,
                                width: laneWidth,
                                xOffset: laneX
                            )
                            .onTapGesture(count: 2) {
                                tagToEdit = info.tag
                            }
                        }
                    }
                    .frame(height: hourHeight * 24)
                }
            }
        }
        .sheet(isPresented: $showAddTag) {
            AddTagView(selectedDate: selectedDate)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(item: $tagToEdit) { tag in
            EditTagView(tag: tag)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
