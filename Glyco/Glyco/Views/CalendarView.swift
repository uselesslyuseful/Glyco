
import SwiftUI

enum CalendarScreen {
    case month
    case week(Date)
    case day(Date)
}

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var screen: CalendarScreen = .month

    var body: some View {
        VStack {
            switch screen {

            case .month:
                MonthView { selectedDate in
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
