//
//  GlycoApp.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-01-20.
//

import SwiftUI
import CoreData

@main
struct GlycoApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var dexcom = DexcomClient()
    @StateObject private var insightsVM = InsightsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dexcom)
                .environmentObject(insightsVM)
        }

    }
}
