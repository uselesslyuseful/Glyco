import SwiftUI

struct MeetingView: View {
    @EnvironmentObject var afvm: AutoFetchViewModel
    @EnvironmentObject var ivm: InsightsViewModel
    @EnvironmentObject var gvm: GraphViewModel
    @EnvironmentObject var tvm: TrendViewModel
    @EnvironmentObject var dexcom: DexcomClient
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack(spacing: 20) {

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

            if dexcom.isAuthenticated {

                Button("Clear Data") {
                    Task {
                        await deleteAllGlucoseEntries(with: viewContext)
                        await MainActor.run {
                            ivm.loadStats(context: viewContext)
                            gvm.loadStats(context: viewContext)
                            tvm.loadStats(context: viewContext)
                        }
                    }
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

    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }


}
