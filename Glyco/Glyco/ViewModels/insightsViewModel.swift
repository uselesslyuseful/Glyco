//
//  insightsViewModel.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-02-18.
//

import Foundation
import Combine
import CoreData

class InsightsViewModel: ObservableObject {
    @Published var average: Double = 0
    @Published var percHigh: Double = 0
    @Published var percLow: Double = 0
    let highThreshold: Double = 10
    let lowThreshold: Double = 3

    func loadStats(context: NSManagedObjectContext) {
        let glucose = fetchGlucoseEntries(with: context)

        guard !glucose.isEmpty else { return }

        let values = glucose.map { $0.value }

        average = values.reduce(0, +) / Double(values.count) // calculate the sum of all numeric elements in an array/len(arr)
        
        var highCount = 0
        var lowCount = 0
        for g in values{
            if g > highThreshold{
                highCount += 1
            }else if g < lowThreshold{
                lowCount += 1
            }
        }
        percHigh =
    }
}
