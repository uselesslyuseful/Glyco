import Foundation
import CoreData

//
//  GlucoseSamples.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-02-04.
//

// just creating sample data for us to work with. Remember this is raw data - what will the API give us?
// Even then in this case the data will be a lot more formatted -- it will clearly have ID, value, and date.
// API might just give a string of integers that we need to split to extrapolate data. We assume it gives us the above line for now.


func addEntry(glucoseValue: Double, dateEntered: Date, context: NSManagedObjectContext) {
    let entry = GlucoseEntry(context: context)
    entry.value = glucoseValue
    entry.date = dateEntered
    
    do {
        try context.save()
        print("GlucoseEntry saved")
        print("GlucoseEntry — Value: \(entry.value), Date: \(entry.date)")
    } catch {
        // Handle the error appropriately
        print("Failed to save GlucoseEntry: \(error)")
    }
}

func addRandomSampleData(context: NSManagedObjectContext){
    Task {
          while true {
              await MainActor.run {
                  addEntry(
                      glucoseValue: Double.random(in: 4.0...9.0),
                      dateEntered: Date().addingTimeInterval(Double.random(in: -10_000.0...0.0)),
                      context: context
                  )
              }
              try? await Task.sleep(nanoseconds: 1_000_000_000)
          }
      }
}

func startRandomSampling(with context: NSManagedObjectContext) {
    addRandomSampleData(context: context)
}

