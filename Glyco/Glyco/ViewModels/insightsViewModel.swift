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

    func loadStats(context: NSManagedObjectContext) {
        let glucose = fetchGlucoseEntries(with: context)

        guard !glucose.isEmpty else { return }

        let values = glucose.map { $0.value }

        average = values.reduce(0, +) / Double(values.count) // calculate the sum of all numeric elements in an array/len(arr)
        percHigh = values.max() ?? 0
        percLow = values.min() ?? 0
    }
}
