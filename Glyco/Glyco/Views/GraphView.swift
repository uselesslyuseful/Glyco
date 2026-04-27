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
    @EnvironmentObject var gvm: GraphViewModel
    @EnvironmentObject var tvm: TrendViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @State private var insightRangeText = "1 Day" // ALSO DEFAULT VALUE HEREE
    @State private var isShowingRangePicker = false
    
    @State private var minutes: Int = 0
    @State private var hours: Int = 0 // DEFAULT VALUE HEREEEEEE
    @State private var days: Int = 1
    
    
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
        .frame(width: UIScreen.main.bounds.width * 0.95)
        .onAppear {
            gvm.loadStats(context: viewContext)
            tvm.loadStats(context: viewContext)
        }
        .sheet(isPresented: $isShowingRangePicker) {
            VStack(spacing: 24) {
                Text("Time Range")
                    .font(.headline)
                Text("Pick time range for the data below.")
                    .foregroundStyle(.secondary)
                TimePicker(minutes: $minutes, hours: $hours, days: $days)
                
                
                //Maybe instead?? (updates every time the wheel is moved kinda) prolly not
//                    .onChange(of: gvm.dateL) { _ in
//                        gvm.loadStats(context: viewContext)
//                    }

                HStack(spacing: 16) {
                    Button("Cancel") { isShowingRangePicker = false }
                    Button("Apply") {
                        isShowingRangePicker = false
                        insightRangeText = TimePicker.rangeToString(minutes: minutes, hours: hours, days: days)
                        let totalMinutes = minutes + (hours * 60) + (days * 24 * 60)
                        let sinceDate = Calendar.current.date(byAdding: .minute, value: -totalMinutes, to: Date()) ?? Date()

                        gvm.dateL = sinceDate
                        gvm.loadStats(context: viewContext)

                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .presentationDetents([.fraction(0.45), .medium])
            
        }
        Infobar(
            title: "Rate",
            value1: tvm.rateText,
            value2: "\(tvm.rate)",
            altValue: "mmol/min",
            systemImages: [tvm.icons[0], tvm.icons[1]],
            accentColor: tvm.accent ?? .accentColor
        )
        .frame(width: UIScreen.main.bounds.width * 0.95)
    }
    
}


struct Graph: View {
    @EnvironmentObject var ivm: InsightsViewModel
    @EnvironmentObject var gvm: GraphViewModel
    
    @AppStorage("highLimit") var highThreshold: Double = 10.0
    @AppStorage("lowLimit") var lowThreshold: Double = 3.9
    
    var body: some View {
        Chart {
            ForEach(gvm.filteredList, id: \.self) { entry in
                LineMark(
                    x: .value("Time", entry.date ?? Date()),
                    y: .value("Level", entry.value)
                )
            }
            PointMark( // force graph to extend to "now"
                x: .value("Time", Date()),
                y: .value("Level", 7)
            )
            .opacity(0)
            
            if let latest = gvm.filteredList.last, let date = latest.date {
                PointMark(
                    x: .value("Time", date),
                    y: .value("Level", latest.value)
                )
                .foregroundStyle(.blue)
                .symbolSize(50)
            }
            RuleMark(y: .value("High", highThreshold))
                .foregroundStyle(.red.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1))
            
            RuleMark(y: .value("Low", lowThreshold))
                .foregroundStyle(.red.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1))

            RuleMark(y: .value("Average", ivm.averagemmol))
                .foregroundStyle(.teal.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: ticks()) { value in
                AxisGridLine()
                AxisValueLabel(anchor: .topTrailing) {
                    if let date = value.as(Date.self) {
                        Text(relativeLabel(for: date))
                            .font(.system(size: 9))
                    }
                }
            }
            AxisMarks(values: [Date()]) { _ in
                AxisGridLine()
                AxisValueLabel(anchor: .topTrailing){
                    Text("now")
                        .font(.system(size: 9))
                }
            }
        }
        
        .aspectRatio(1, contentMode: .fit)
        
    }
    
    private func relativeLabel(for date: Date) -> String {
        let diff = Int(Date().timeIntervalSince(date))
        if diff < 60*5 { // 1 min or 5 mins?
            return ""
        } else if diff < 3600 { // <60 mins
            return "\(diff / 60)m ago"
        } else if diff < 86400{  // < 1 day
            return "\(diff / 3600)h ago"
        }else{
            return "\(diff / 86400)d ago"
        }
    }
    
    private func ticks() -> [Date] {
        let earliest = gvm.dateL
                
        let totalMinutes = Int(Date().timeIntervalSince(earliest) / 60)
        
        let intervalMinutes: Int
        switch totalMinutes {
        case 0..<8:        intervalMinutes = 5
        case 8..<15:       intervalMinutes = 5
        case 15..<30:      intervalMinutes = 10
        case 30..<60:      intervalMinutes = 15
        case 60..<90:      intervalMinutes = 20
        case 90..<120:     intervalMinutes = 30
        case 120..<180:    intervalMinutes = 45
        case 180..<240:    intervalMinutes = 60
        case 240..<360:    intervalMinutes = 90
        case 360..<480:    intervalMinutes = 120
        case 480..<720:    intervalMinutes = 180
        case 720..<960:    intervalMinutes = 240
        case 960..<1440:   intervalMinutes = 360
        case 1440..<2880:  intervalMinutes = 480
        case 2880..<4320:  intervalMinutes = 720
        case 4320..<8640:  intervalMinutes = 1440
        default:           intervalMinutes = 2880
        }
        
        let intervalSeconds = Double(intervalMinutes * 60)
        
        var ticks: [Date] = []
        var current = Date().addingTimeInterval(-intervalSeconds)
        while current > earliest {
            ticks.append(current)
            current = current.addingTimeInterval(-intervalSeconds)
        }
        return ticks.reversed()
    }
}
struct Infobar: View {
    let title: String
    let value1: String
    let value2: String?
    let altValue: String?
    let systemImages: [String]?
    let accentColor: Color

    init(title: String = "Name", value1: String = "Value", value2: String? = nil, altValue: String? = nil, systemImages: [String]? = nil, accentColor: Color = .accentColor) {
        self.title = title
        self.value1 = value1
        self.value2 = value2
        self.altValue = altValue
        self.systemImages = systemImages
        self.accentColor = accentColor
    }

    var body: some View {
        HStack(spacing: 10) {

            if let systemImages, let first = systemImages.first, !first.isEmpty {
                Image(systemName: first)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(accentColor)
                    .frame(width: 28, height: 28)
                    .background(accentColor.opacity(0.12), in: Circle())
            }

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)

            Spacer()

            HStack(spacing: 6) {
                if let value2 {
                    Text(value2)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
                if let altValue {
                    Text(altValue)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }

                
                Text(value1)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(accentColor.opacity(0.12), in: Capsule())
                
                if let systemImages, systemImages.indices.contains(1), !systemImages[1].isEmpty {
                    Image(systemName: systemImages[1])
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(accentColor)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}
