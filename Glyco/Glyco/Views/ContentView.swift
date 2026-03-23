//
//  ContentView.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-01-20.
//

import SwiftUI
import CoreData


//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
struct ContentView: View {
    @EnvironmentObject var ivm: InsightsViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var insightRangeText = "1 Day" // ALSO DEFAULT VALUE HEREE
    @State private var isShowingRangePicker = false
    
    @State private var weeks: Int = 0
    @State private var days: Int = 1 // DEFAULT VALUE HEREEEEEE
    @State private var hours: Int = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    // FIRST ROW (Title and time picker)
                    HStack(spacing: 0){
                        // TITLE
                        Text("Insights")
                            .font(.headline)
                        // BUTTON TO TOGGLE TIME RANGE
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
                    .padding(.top, 12)
                    .padding(.bottom, 0)
                    
                    // Main info
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        alignment: .center,
                        spacing: 10,
                    ){
                        Infocard(
                            title: "Current",
                            value1: "\(ivm.latestmmol)mmol/L",
                            value2: nil,
                            altValue: "\(ivm.latestmgdl)mmol/Lmg/dL",
                            systemImages: ["chart.bar.fill", "", "arrow.up.circle.fill"])
                        Infocard(
                            title: "Average",
                            value1: "\(ivm.averagemmol)mmol/L",
                            value2: nil,
                            altValue: "\(ivm.averagemgdl)mg/dL",
                            systemImages: ["chart.bar.fill"])
                        Infocard(
                            title: "Time in Range",
                            value1: "\(ivm.percIn)%",
                            value2: nil,
                            altValue: nil,
                            systemImages: ["chart.bar.fill"])
                        Infocard(
                            title: "Time Out of Range",
                            value1: "\(ivm.percHigh)%",
                            value2: "\(ivm.percLow)%",
                            altValue: nil,
                            systemImages: ["chart.bar.fill", "arrow.up.circle.fill", "", "arrow.down.circle.fill"])
                    }
                    .padding(.top, 0)
                    .padding(.horizontal, 0)
                    .padding(.bottom, 8)

                                        
                }
                .frame(width: UIScreen.main.bounds.width * 0.95)
                
                SecondBloodGlucoseStatisticsView()
                    .frame(width: UIScreen.main.bounds.width * 0.95)
                
                NavigationLink {
                    MeetingView()
                } label: {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                        Text("Dexcom Data")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
                .frame(width: UIScreen.main.bounds.width * 0.95)
                .padding(.bottom, 8)

            }
            .navigationTitle("Glyco Dashboard") // Title of the page
            // TIME RANGE PICKER
            .onAppear {
                ivm.loadStats(context: viewContext)
                print("wt")
            }
            .sheet(isPresented: $isShowingRangePicker) {
                VStack(spacing: 24) {
                    Text("Time Range")
                        .font(.headline)
                    Text("Pick time range for the data below.")
                        .foregroundStyle(.secondary)
                    TimePicker(weeks: $weeks, days: $days, hours: $hours)
                    
                    
                    //Maybe instead?? (updates every time the wheel is moved kinda) prolly not
//                    .onChange(of: ivm.dateL) { _ in
//                        ivm.loadStats(context: viewContext)
//                    }

                    HStack(spacing: 16) {
                        Button("Cancel") { isShowingRangePicker = false }
                        Button("Apply") {
                            isShowingRangePicker = false
                            insightRangeText = TimePicker.rangeToString(weeks: weeks, days: days, hours: hours)
                            let totalHours = (weeks * 7 + days) * 24 + hours
                            let sinceDate = Calendar.current.date(byAdding: .hour, value: -totalHours, to: Date()) ?? Date()

                            ivm.dateL = sinceDate
                            ivm.loadStats(context: viewContext)

                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .presentationDetents([.fraction(0.45), .medium])
                
            }
        }
        
    }
}


// MARK: - Infocard
struct Infocard: View {
    let title: String
    let value1: String
    let value2: String?
    let altValue: String?
    let systemImages: [String]?
    
    init(title: String = "Name", value1: String = "Value", value2: String? = nil, altValue: String? = nil, systemImages: [String]? = nil) {
        self.title = title
        self.value1 = value1
        self.value2 = value2
        self.altValue = altValue
        self.systemImages = systemImages
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                if let systemImages, let first = systemImages.first, !first.isEmpty {
                    Image(systemName: first).foregroundColor(.accentColor)
                }
                Text(title)
                    .font(.system(size: 12, weight: .regular))

            }
            
            HStack{
                if let systemImages, systemImages.indices.contains(1), !systemImages[1].isEmpty {
                    Image(systemName: systemImages[1]).foregroundColor(.accentColor)

                }

                Text(value1)
                    .font(.system(size: 20, weight: .semibold))
                
                if let systemImages, systemImages.indices.contains(2), !systemImages[2].isEmpty {
                    Image(systemName: systemImages[2]).foregroundColor(.accentColor)

                }

            }
            
            HStack{
                if let systemImages, systemImages.indices.contains(3), !systemImages[3].isEmpty {
                    Image(systemName: systemImages[3]).foregroundColor(.accentColor)

                }
                if let value2, !value2.isEmpty {
                    Text(value2)
                        .font(.system(size: 20, weight: .semibold))
                }
                if let systemImages, systemImages.indices.contains(4), !systemImages[4].isEmpty {
                    Image(systemName: systemImages[4]).foregroundColor(.accentColor)

                }
            }
            

            if let altValue, !altValue.isEmpty {
                Text(altValue)
                    .font(.system(size: 12, weight: .semibold))
            }

            Spacer()
        }
        .padding(8)
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

