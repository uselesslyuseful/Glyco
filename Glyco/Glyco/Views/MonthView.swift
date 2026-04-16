
//
//  MonthView.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-04-13.
//

import SwiftUI

struct MonthView: View {

    var onSelectWeek: (Date) -> Void

    @State private var baseMonth: Date = {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        return Calendar.current.date(from: comps) ?? Date()
    }()

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {

                LazyVStack(spacing: 20) {

                    ForEach(monthOffsets, id: \.self) { offset in

                        let monthDate = Calendar.current.date(
                            byAdding: .month,
                            value: offset,
                            to: baseMonth
                        )!

                        MonthGrid(monthDate: monthDate) { selectedDate in
                            onSelectWeek(selectedDate)
                        }
                        .id(offset)
                    }
                }
                .padding()
            }
            .onAppear {
                DispatchQueue.main.async {
                    proxy.scrollTo(0, anchor: .top) // current month
                }
            }
        }
    }

    // MARK: - RANGE
    private var monthOffsets: [Int] {
        Array((-60)...0) + Array(1...6)
    }
}

struct MonthGrid: View {

    let monthDate: Date
    var onDoubleTap: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        let days = generateDays()

        VStack(alignment: .leading) {
            Text(monthTitle())
                .font(.headline)

            LazyVGrid(columns: columns) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        Text("\(Calendar.current.component(.day, from: date))")
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)

                            .onTapGesture(count: 2) {
                                onDoubleTap(date)
                            }

                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
        }
    }

    private func monthTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: monthDate)
    }

    private func generateDays() -> [Date?] {
        let calendar = Calendar.current

        guard let range = calendar.range(of: .day, in: .month, for: monthDate),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)

        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }

        return days
    }
}
