//
//  insightsViewModel.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-02-18.
//
import SwiftUI
import Foundation
import Combine
import CoreData

class PredictionViewModel: ObservableObject {
    @Published var predictionList: [Prediction] = []
    @Published var isLoading: Bool = false

    
    func predictGlucose(context: NSManagedObjectContext) async {
        await MainActor.run {
                self.isLoading = true
            }
        do {
            let result = try await glucoseAPICall(context: context)
            await MainActor.run {
                self.predictionList = result
                self.isLoading = false
            }

        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            print("Prediction failed:", error)
        }
    }
}
