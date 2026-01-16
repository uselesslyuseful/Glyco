//
//  GlycoApp.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-01-16.
//

import SwiftUI
import CoreData

@main
struct GlycoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
