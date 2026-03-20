//
//  GraphViewModel.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-03-19.
//

import Foundation
import Combine
import CoreData

class GraphViewModel: ObservableObject {
    @Published var filteredList: [GlucoseEntry] = []
    @Published var dateL: Date = Date().addingTimeInterval(-24*60*60)

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
    }
}
