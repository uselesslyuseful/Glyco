//
//  MeetingView.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-02-18.
//


import SwiftUI

struct MeetingView: View {
    @EnvironmentObject var dexcom: DexcomClient

    var body: some View {
        VStack(spacing: 20) {

            if dexcom.isAuthenticated {
                Button("Fetch Glucose Data") {
                    Task {
                        await dexcom.fetchEGVs()
                    }
                }

                List(dexcom.glucoseValues) { egv in
                    VStack(alignment: .leading) {
                        Text("\(egv.value) mg/dL")
                            .font(.headline)
                        Text(egv.timestamp, style: .time)
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
