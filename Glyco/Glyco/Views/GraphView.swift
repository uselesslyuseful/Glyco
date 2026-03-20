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
                
                Text("Glucose Levels.")
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
                Spacer()            }
            
            Chart {
                ForEach(vm.filteredList, id: \.type) { dataSeries in
                    ForEach(dataSeries.bloodglucoseData) { point in
                        LineMark(
                            x: .value("Hour", point.hour),
                            y: .value("Level", point.level)
                                
                        )
                            
                        }
                        .foregroundStyle(by: .value("Person", dataSeries.type))
                        .symbol(by: .value("Person", dataSeries.type))
                    }
                }


            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXScale(domain: [100, 0]) //TODO: Specific value instead of 100
            
            .aspectRatio(1, contentMode: .fit)
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

