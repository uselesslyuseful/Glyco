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
    @Published var latestmmol: Double = 0
    @Published var latestmgdl: Double = 0
    @Published var averagemmol: Double = 0
    @Published var averagemgdl: Double = 0
    @Published var percHigh: Double = 0
    @Published var percLow: Double = 0
    @Published var percIn: Double = 0
    @Published var filteredList: [GlucoseEntry] = []
    @Published var dateL: Date = Date().addingTimeInterval(-24*60*60)
    @AppStorage("highLimit") var highThreshold: Double = 10.0
    @AppStorage("lowLimit") var lowThreshold: Double = 3.9

    func loadStats(context: NSManagedObjectContext) {
        let glucose = fetchGlucoseEntries(with: context)

        guard !glucose.isEmpty else { return }
        filteredList.removeAll()
        for g in glucose{
            if let entryDate = g.date{
                if entryDate > dateL{
                    filteredList.append(g)
                }
            }
        }
        let values = filteredList.map { $0.value }

        averagemmol = values.reduce(0, +) / Double(values.count) // calculate the sum of all numeric elements in an array/len(arr)
        averagemgdl = round(value: averagemmol*18, toDecimalPlaces: 1)
        averagemmol = round(value: averagemmol, toDecimalPlaces: 1)
        
        
        var highCount = 0
        var lowCount = 0
        for g in values{
            if g > highThreshold{
                highCount += 1
            }else if g < lowThreshold{
                lowCount += 1
            }
        }
        percHigh = Double(highCount)/Double(values.count) * 100
        percHigh = round(value: percHigh, toDecimalPlaces: 1)
        percLow = Double(lowCount)/Double(values.count) * 100
        percLow = round(value: percLow, toDecimalPlaces: 1)
        percIn = Double(values.count-(lowCount+highCount))/Double(values.count) * 100
        percIn = round(value: percIn, toDecimalPlaces: 1)
        
        latestmmol = round(value: glucose[0].value, toDecimalPlaces: 1)
        latestmgdl = round(value: glucose[0].value*18, toDecimalPlaces: 1)

        
        
    }
}

// MARK: - Helper functions for math
func round(value: Double, toDecimalPlaces places: Int) -> Double {
    let multiplier = pow(10.0, Double(places))
    let roundedValue = (value * multiplier).rounded() / multiplier
    return roundedValue
}
// cant believe swift doesn't have a function to round to specific decimal places
