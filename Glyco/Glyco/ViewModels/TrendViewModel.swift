//
//  TrendViewModel.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-03-25.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class TrendViewModel: ObservableObject {
    @Published var sortedGlucose: [GlucoseEntry] = []
    @Published var filteredList: [GlucoseEntry] = []
    @Published var dateL: Date = Date().addingTimeInterval(-24*60*60)
    @Published var rate: Double = 0
    @Published var rateText: String = "--"
    @Published var icons: [String] = ["questionmark", "questionmark.circle.fill"]
    @Published var accent: Color?
   
    
    func loadStats(context: NSManagedObjectContext) {
        let glucose = fetchGlucoseEntries(with: context)

        sortedGlucose = glucose.sorted { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) } //latest at 0

        guard sortedGlucose.count >= 2 else {
            return
        }

        let first = sortedGlucose[0]
        let second = sortedGlucose[1]

        guard let firstDate = first.date,
              let secondDate = second.date,
              let firstValue = first.value as Double?,
              let secondValue = second.value as Double? else {
            return
        }

        rate = round(value: (secondValue - firstValue)/(secondDate.timeIntervalSince1970 - firstDate.timeIntervalSince1970)*60, toDecimalPlaces: 2) //slope (rate of change per second)*60
        // gives rate of change in mmol/L per minute
        
        if rate > 0.1 {
            icons = ["arrow.up", "arrow.up.circle.fill"]
            rateText = "Rising Rapidly"
            accent = .red
        } else if rate >= 0.06 {
            icons = ["arrow.up.right", "arrow.up.right.circle.fill"]
            rateText = "Rising Moderately"
            accent = .orange
        } else if rate >= -0.06 {
            icons = ["arrow.right", "arrow.right.circle.fill"]
            rateText = "Stable"
            accent = .teal
        } else if rate >= -0.1 {
            icons = ["arrow.down.right", "arrow.down.right.circle.fill"]
            rateText = "Falling Moderately"
            accent = .orange
        } else {
            icons = ["arrow.down", "arrow.down.circle.fill"]
            rateText = "Falling Rapidly"
            accent = .red
        }
    }
}

