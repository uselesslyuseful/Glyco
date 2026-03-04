//
//  MeetingView.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-02-18.
//


import SwiftUI

struct MeetingView: View {
    @StateObject private var vm = InsightsViewModel()
    @EnvironmentObject var dexcom: DexcomClient
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack(spacing: 20) {

            if dexcom.isAuthenticated {
                Button("Fetch Glucose Data") {
                    Task {
                        await dexcom.fetchEGVs()
                        dexcom.importEGVsIntoCoreData(context: viewContext)
                    }
                    let glucose = fetchGlucoseEntries(with: viewContext)
                    vm.loadStats(context: viewContext)
                }
                Button("Clear Data") {
                    deleteAllGlucoseEntries(with: viewContext)
                }

                List(dexcom.glucoseValues, id: \.systemTime) { egv in
                    VStack(alignment: .leading) {
                        Text("\(egv.value) mg/dL")
                            .font(.headline)
                        Text(egv.systemTime)
                            .font(.caption)
                    }
                }

            } else {
                Button("Connect Dexcom") {
                    dexcom.login()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationTitle("Dexcom")
    }
}
