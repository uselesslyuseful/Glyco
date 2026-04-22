
import SwiftUI

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
                DayView(selectedDate: .constant(date))
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

            ToolbarItem(placement: .topBarTrailing) {
                Button("Sort") {
                    showingSortSheet = true
                }
            }
        }
        .sheet(isPresented: $showingSortSheet) {
            TagFilterView(tags: allTags, selectedTags: $selectedTags)
        }
    }

    // MARK: - Logic

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
