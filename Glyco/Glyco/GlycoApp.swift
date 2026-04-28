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
    @StateObject private var graphVM = GraphViewModel()
    @StateObject private var trendVM = TrendViewModel()
    @StateObject private var userData = UserData()
    @StateObject private var predictionVM = PredictionViewModel()
    @StateObject private var autoFetchVM: AutoFetchViewModel
    
    init() {
        let persistenceController = PersistenceController.shared

        let dexcom = DexcomClient()
        let insightsVM = InsightsViewModel()
        let graphVM = GraphViewModel()
        let trendVM = TrendViewModel()
        let predictionVM = PredictionViewModel()

        _dexcom = StateObject(wrappedValue: dexcom)
        _insightsVM = StateObject(wrappedValue: insightsVM)
        _graphVM = StateObject(wrappedValue: graphVM)
        _trendVM = StateObject(wrappedValue: trendVM)
        _predictionVM = StateObject(wrappedValue: predictionVM)
        

        let context = persistenceController.container.viewContext

        _autoFetchVM = StateObject(
            wrappedValue: AutoFetchViewModel(
                dexcom: dexcom,
                context: context,
                ivm: insightsVM,
                gvm: graphVM,
                tvm: trendVM,
                pvm: predictionVM
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dexcom)
                .environmentObject(insightsVM)
                .environmentObject(graphVM)
                .environmentObject(trendVM)
                .environmentObject(userData)
                .environmentObject(predictionVM)
                .environmentObject(autoFetchVM)
        }

    }
}
