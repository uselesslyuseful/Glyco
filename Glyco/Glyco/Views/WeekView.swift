//
//  WeekView.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-04-13.
//

import SwiftUI

struct WeekView: View {

    let selectedDate: Date
    var onSelectDay: (Date) -> Void

    var body: some View {
        let week = generateWeek(from: selectedDate)

        VStack {
            HStack(spacing: 10) {
                ForEach(week, id: \.self) { date in
                    Button {
                        onSelectDay(date)
                    } label: {
                        VStack {
                            Text(dayLetter(from: date))
                                .font(.caption)

                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(isToday(date) ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .padding()

            Spacer()

            Text("Select a day")
                .foregroundColor(.gray)

            Spacer()
        }
    }

    private func generateWeek(from date: Date) -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)!.start

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }

    private func dayLetter(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}
