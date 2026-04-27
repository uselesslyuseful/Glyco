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

    
    func predictGlucose(context: NSManagedObjectContext) async {
        do {
            let result = try await glucoseAPICall(context: context)
            self.predictionList = result

        } catch {
            print("Prediction failed:", error)
        }
    }
}
