
import SwiftUI
import CoreData

enum CalendarScreen {
    case month
    case week(Date)
    case day(Date)
}

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var screen: CalendarScreen = .month
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.title, ascending: true)]
    ) private var allTags: FetchedResults<Tag>

    @State private var selectedTags: Set<Tag> = []
    @State private var showingSortSheet = false
    @Environment(\.managedObjectContext) private var context
    @State private var showingTrackers = false

    var body: some View {
        VStack {
            switch screen {

            case .month:
                MonthView(
                    selectedTags: selectedTags
                ) { selectedDate in
                    screen = .week(selectedDate)
                }

            case .week(let date):
                WeekView(selectedDate: date) { selectedDay in
                    screen = .day(selectedDay)
                }

            case .day(let date):
                DayView(
                    selectedDate: .constant(date),
                    selectedTags: selectedTags
                )
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)

        .navigationBarBackButtonHidden(true)

        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    handleBack()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(backButtonTitle())
                    }
                }
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Sort") {
                    showingSortSheet = true
                }

                Button("Trackers") {
                    showingTrackers = true
                }
            }
        }
        .sheet(isPresented: $showingSortSheet) {
            TagFilterView(tags: allTags, selectedTags: $selectedTags)
        }
        .sheet(isPresented: $showingTrackers) {
            TrackerView()
        }
        .onAppear {
            createDefaultTags(context: context)
        }
    }

    func createDefaultTags(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "isSystem == YES")

        let existing = (try? context.fetch(request)) ?? []

        if !existing.isEmpty { return }

        let defaults = [
            ("Menstrual Cycle", "#E57373"),
            ("Stress", "#FFB74D"),
            ("Exercise", "#FEFF00"),
            ("Sleep", "#64B5F6"),
        ]

        for (name, color) in defaults {
            let tag = Tag(context: context)
            tag.id = UUID()
            tag.title = name
            tag.colorHex = color
            tag.isSystem = true
        }

        try? context.save()
    }

    private func handleBack() {
        switch screen {
        case .month:
            dismiss() // 👈 go back to home

        case .week:
            screen = .month

        case .day(let date):
            screen = .week(date)
        }
    }

    private func backButtonTitle() -> String {
        switch screen {
        case .month:
            return "Home"
        case .week:
            return "Month"
        case .day:
            return "Week"
        }
    }
}
