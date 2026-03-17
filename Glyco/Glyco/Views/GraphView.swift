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
enum TimeRange: String, CaseIterable, Identifiable {
    case threeHours = "3 Hours"
    case sixHours = "6 Hours"
    case twelveHours = "12 Hours"
    case twentyFourHours = "24 Hours"
    
    var id: String { self.rawValue }
}

struct SecondBloodGlucoseStatisticsView: View {
    
    @State private var selectedRange: TimeRange = .threeHours
    
    let person1data = BloodGlucoseData.person1Examples
    
    var data: [(type: String, bloodglucoseData: [BloodGlucoseData])] {
        [(type: "Person 1", bloodglucoseData: filteredPerson1)]
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                
                // Add the blue icon with 3 bars here
                
                Text("Hourly Avg.")
                        .font(.headline)
                        .padding(.leading, 8)
                
                Picker("", selection: $selectedRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue)
                            .tag(range)
                    }
                }
                .pickerStyle(.menu)
                .tint(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 0)
                .background(Color(.systemGray5))
                .cornerRadius(30)
            }
            
            Chart {
                ForEach(data, id: \.type) { dataSeries in
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
            
            .aspectRatio(1, contentMode: .fit)
        }
        .tint(.black)
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .frame(width: 350)
    }
    
    var filteredPerson1: [BloodGlucoseData] {
        filter(data: person1data)
    }
    
    func filter(data: [BloodGlucoseData]) -> [BloodGlucoseData] {
        switch selectedRange {
        case .threeHours:
            return Array(data.prefix(3))
        case .sixHours:
            return Array(data.prefix(6))
        case .twelveHours:
            return Array(data.prefix(12))
        case .twentyFourHours:
            return data
        }
    }
}
