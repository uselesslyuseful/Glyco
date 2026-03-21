//
//  GraphView.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-03-02.
//

import SwiftUI
import CoreData
import Charts
// MARK: - Graph
struct SecondBloodGlucoseStatisticsView: View {
    @EnvironmentObject var vm: GraphViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @State private var insightRangeText = "1 Day" // ALSO DEFAULT VALUE HEREE
    @State private var isShowingRangePicker = false
    
    @State private var minutes: Int = 0
    @State private var hours: Int = 1 // DEFAULT VALUE HEREEEEEE
    @State private var days: Int = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                
                // Add the blue icon with 3 bars here
                
                Text("Glucose Levels")
                    .font(.headline)
                    .padding(.leading, 8)
                
                Button(action: { isShowingRangePicker = true }) {
                    HStack(spacing: 6) {
                        Text(insightRangeText)
                            .foregroundStyle(.gray)
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .layoutPriority(1)
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal, 16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                Spacer()
            }
            Graph()
        }
        .tint(.black)
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .frame(width: 350)
        .sheet(isPresented: $isShowingRangePicker) {
            VStack(spacing: 24) {
                Text("Time Range")
                    .font(.headline)
                Text("Pick time range for the data below.")
                    .foregroundStyle(.secondary)
                TimePicker(minutes: $minutes, hours: $hours, days: $days)
                
                
                //Maybe instead?? (updates every time the wheel is moved kinda) prolly not
//                    .onChange(of: vm.dateL) { _ in
//                        vm.loadStats(context: viewContext)
//                    }

                HStack(spacing: 16) {
                    Button("Cancel") { isShowingRangePicker = false }
                    Button("Apply") {
                        isShowingRangePicker = false
                        insightRangeText = TimePicker.rangeToString(minutes: minutes, hours: hours, days: days)
                        let totalMinutes = minutes + (hours * 60) + (days * 24 * 60)
                        let sinceDate = Calendar.current.date(byAdding: .minute, value: -totalMinutes, to: Date()) ?? Date()

                        vm.dateL = sinceDate
                        vm.loadStats(context: viewContext)

                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .presentationDetents([.fraction(0.45), .medium])
        }
    }
    
}


struct Graph: View {
    @EnvironmentObject var vm: GraphViewModel
    
    var body: some View {
        Chart {
            ForEach(vm.filteredList, id: \.self) { entry in
                LineMark(
                    x: .value("Time", entry.date ?? Date()),
                    y: .value("Level", entry.value)
                )
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(relativeLabel(for: date))
                            .font(.system(size: 10))
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func relativeLabel(for date: Date) -> String {
        let diff = Int(Date().timeIntervalSince(date))
        if diff < 60 { // 1 min or 5 mins?
            return "now"
        } else if diff < 3600 { // <60 mins
            return "\(diff / 60)m ago"
        } else if diff % 3600 == 0 {  // hours only
            return "\(diff / 3600)h ago"
        } else if diff < 86400{ // <1 day
            let h = diff / 3600
            let m = (diff % 3600) / 60
            return "\(h)h\(m)m ago"
        } else{
            let d = diff / 86400
            let h = (diff % 86400) / 3600
            let m = (diff % 3600) / 60
            return "\(d)d\(h)h\(m)m ago"
        }
    }
}

