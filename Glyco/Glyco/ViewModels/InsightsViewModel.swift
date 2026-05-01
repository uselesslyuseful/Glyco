//
//  insightsViewModel.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-02-18.
//
import SwiftUI
import Foundation
import Combine
import CoreData

class InsightsViewModel: ObservableObject {
    @Published var latestmmol: Double?
    @Published var latestmgdl: Double?
    @Published var averagemmol: Double?
    @Published var averagemgdl: Double?
    @Published var percHigh: Double?
    @Published var percLow: Double?
    @Published var percIn: Double?
    @Published var filteredList: [GlucoseEntry] = []
    @Published var dataPresent: Bool = false
    @Published var dateL: Date = Date().addingTimeInterval(-24*60*60)
    @AppStorage("highLimit") var highThreshold: Double = 10.0
    @AppStorage("lowLimit") var lowThreshold: Double = 3.9
    @AppStorage("preferredUnit") var selectedUnit = "mmol/L"

    
    func loadStats(context: NSManagedObjectContext) {
        let glucose = fetchGlucoseEntries(with: context)

        guard !glucose.isEmpty else {
            dataPresent = false
            filteredList.removeAll()
            latestmmol = nil
            latestmgdl = nil
            averagemmol = nil
            averagemgdl = nil
            percHigh = nil
            percLow = nil
            percIn = nil
            return
        }

        dataPresent = true
        
        filteredList.removeAll()
        for g in glucose{
            if let entryDate = g.date{
                if entryDate > dateL{
                    filteredList.append(g)
                }
            }
        }
        
        let latestValue = glucose[0].value
        latestmmol = round(value: latestValue, toDecimalPlaces: 1)
        latestmgdl = round(value: latestValue * 18, toDecimalPlaces: 1)

        guard !filteredList.isEmpty else {
            latestmmol = nil
            latestmgdl = nil
            averagemmol = nil
            averagemgdl = nil
            percHigh = nil
            percLow = nil
            percIn = nil
            return
        }

        let values: [Double] = filteredList.map { $0.value }

        let avgMmolRaw = values.reduce(0, +) / Double(values.count)
        let avgMmol = round(value: avgMmolRaw, toDecimalPlaces: 1)
        let avgMgdl = round(value: avgMmol * 18, toDecimalPlaces: 1)

        averagemmol = avgMmol
        averagemgdl = avgMgdl
        
        
        var highCount = 0
        var lowCount = 0
        for g in values{
            if g > highThreshold{
                highCount += 1
            }else if g < lowThreshold{
                lowCount += 1
            }
        }
        let total = Double(values.count)
        let pHigh = round(value: (Double(highCount) / total) * 100, toDecimalPlaces: 1)
        let pLow = round(value: (Double(lowCount) / total) * 100, toDecimalPlaces: 1)
        let pIn = round(value: (Double(values.count - (lowCount + highCount)) / total) * 100, toDecimalPlaces: 1)

        percHigh = pHigh
        percLow = pLow
        percIn = pIn

    }
}

// MARK: - Helper functions for math
func round(value: Double, toDecimalPlaces places: Int) -> Double {
    let multiplier = pow(10.0, Double(places))
    let roundedValue = (value * multiplier).rounded() / multiplier
    return roundedValue
}
// cant believe swift doesn't have a function to round to specific decimal places

