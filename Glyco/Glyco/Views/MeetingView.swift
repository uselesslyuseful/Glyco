import SwiftUI

struct MeetingView: View {
    @State private var timer: Timer?

    @EnvironmentObject var vm: InsightsViewModel
    @EnvironmentObject var dexcom: DexcomClient
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack(spacing: 20) {

            if dexcom.isAuthenticated {

                Button("Clear Data") {
                    Task {
                        await deleteAllGlucoseEntries(with: viewContext)
                        await MainActor.run {
                            vm.loadStats(context: viewContext)
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

        .onAppear {
            startAutoFetch()
        }

        .onDisappear {
            timer?.invalidate()
        }
    }

    func startAutoFetch() {

        // run immediately once
        Task {
            await runFetch()
        }

        // then repeat every 5 minutes
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            Task {
                await runFetch()
            }
        }
    }

    func runFetch() async {
        await dexcom.fetchEGVs()
        dexcom.importEGVsIntoCoreData(context: viewContext)

        await MainActor.run {
            vm.loadStats(context: viewContext)
        }
    }
}
