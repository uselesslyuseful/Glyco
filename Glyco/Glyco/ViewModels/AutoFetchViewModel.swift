//
//  AutoFetchViewModel.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-04-20.
//

import Foundation
import Combine
import CoreData

class AutoFetchViewModel: ObservableObject {
    @Published var secondsUntilNextFetch: Int = 0
    @Published var isAutoFetchActive: Bool = true
    
    private var timer: Timer?
    private var countdownTimer: Timer?

    private let dexcom: DexcomClient
    private let context: NSManagedObjectContext
    private let ivm: InsightsViewModel
    private let gvm: GraphViewModel
    private let tvm: TrendViewModel
    private let pvm: PredictionViewModel

    init(
        dexcom: DexcomClient,
        context: NSManagedObjectContext,
        ivm: InsightsViewModel,
        gvm: GraphViewModel,
        tvm: TrendViewModel,
        pvm: PredictionViewModel
    ) {
        self.dexcom = dexcom
        self.context = context
        self.ivm = ivm
        self.gvm = gvm
        self.tvm = tvm
        self.pvm = pvm
    }

    func startAutoFetch() {
        isAutoFetchActive = true
        secondsUntilNextFetch = 120

        timer?.invalidate()
        countdownTimer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { _ in
            Task {
                await self.runFetch()
                await MainActor.run {
                    self.secondsUntilNextFetch = 120
                }
            }
        }

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                if self.secondsUntilNextFetch > 0 {
                    self.secondsUntilNextFetch -= 1
                }
            }
        }
    }
    
    func stopAutoFetch() {
        timer?.invalidate()
        countdownTimer?.invalidate()
        timer = nil
        countdownTimer = nil
        isAutoFetchActive = false
    }

    func resetCountdown() {
        secondsUntilNextFetch = 120
    }
    
    func runFetch() async {
        await dexcom.fetchEGVs()
        dexcom.importEGVsIntoCoreData(context: context)

        await MainActor.run {
            ivm.loadStats(context: context)
            gvm.loadStats(context: context)
            tvm.loadStats(context: context)
            Task {
                await pvm.predictGlucose(context: context)
            }
        }
    }
}
