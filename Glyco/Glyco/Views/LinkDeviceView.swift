//
//  LinkDeviceView.swift
//  GlycoPersonal
//
//

import SwiftUI

struct LinkDeviceButton: View {
    let label: String
    
    var body: some View {
        
        Text(label)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .foregroundColor(.black)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.black, lineWidth: 1)
            )
            .padding(.horizontal, 40)
    }
}

struct LinkDeviceView: View {
    @EnvironmentObject var dexcom: DexcomClient
    @EnvironmentObject var vm: InsightsViewModel
    @EnvironmentObject var afvm: AutoFetchViewModel
    @EnvironmentObject var pvm: PredictionViewModel
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        Divider()
        VStack {
            VStack(alignment: .leading) {
                Text("Blood Glucose Monitor")
                    .padding(10)
                    .bold()
                Text("          Current Device")
                
                //CHANGE DESTINATION TO POP-UP TO LINK DEVICES
                
                Button {
                    Task {
                        if dexcom.isAuthenticated {
                            await dexcom.fetchEGVs()
                            await dexcom.importEGVsIntoCoreData(context: viewContext)
                            await MainActor.run {
                                vm.loadStats(context: viewContext)
                            }
                        } else {
                            dexcom.login()
                        } // tehres a video on how steam is the only monopoly who isnt fking the consumer
                    }
                } label: {
                    LinkDeviceButton(label: dexcom.isAuthenticated ? "Sync Dexcom Data" : "Connect Dexcom")
                }
                .padding(10)
                
                Button {
                    Task {
                        await pvm.predictGlucose(context: viewContext)
                    }
                } label: {
                    LinkDeviceButton(label: "Refresh Predictions")
                }
                Spacer()
                HStack {
                    if afvm.isAutoFetchActive {
                        if afvm.secondsUntilNextFetch > 0 {
                            Text("Next update in \(formattedTime(afvm.secondsUntilNextFetch))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Updating…")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Auto-fetch paused")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if afvm.isAutoFetchActive {
                        Button("Stop") {
                            afvm.stopAutoFetch()
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button("Start") {
                            afvm.startAutoFetch()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(20)
            Spacer().frame(height: 60)
        }
        .padding()
        .navigationTitle("Link Device")
        .navigationBarTitleDisplayMode(.inline)

    }
    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

struct LinkDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LinkDeviceView()
        }
    }
}
