//
//  MeetingView.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-02-18.
//


import SwiftUI

struct MeetingView: View {
    @EnvironmentObject var vm: InsightsViewModel
    @EnvironmentObject var dexcom: DexcomClient
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack(spacing: 20) {

            if dexcom.isAuthenticated {
                Button("Clear Data") {
                    Task{
                        await deleteAllGlucoseEntries(with: viewContext)
                        await MainActor.run{
                            vm.loadStats(context: viewContext)
                        }
                    } // TODO: adoinalwd
                    // in retrospect, should have been more specific. no clue what i had to do.
                    
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

