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

// MARK: - Add Data
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

// MARK: - Fetch Data
func fetchGlucoseEntries(with context: NSManagedObjectContext) -> [GlucoseEntry] {
    let request: NSFetchRequest<GlucoseEntry> = GlucoseEntry.fetchRequest()
    do {
        let glucose = try context.fetch(request)
        return glucose
    } catch {
        print("Failed to fetch GlucoseEntries: \(error)")
        return []
    }
}

// MARK: - Delete Data
func deleteAllGlucoseEntries(with context: NSManagedObjectContext) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GlucoseEntry")
    let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
        try context.execute(batchDelete)
        try context.save()
    } catch {
        print("Failed to delete all glucose entries: \(error)")
    }
}

// MARK: - skibidi
struct BloodGlucoseData: Identifiable, Equatable {
    let hour: Int
    
    let level: Double
    
    var id: Int { hour }
    
    static var person1Examples: [BloodGlucoseData] {
        [BloodGlucoseData(hour: 1, level: 2.4),
         BloodGlucoseData(hour: 2, level: 3.3),
         BloodGlucoseData(hour: 3, level: 12.9),
         BloodGlucoseData(hour: 4, level: 4.5)]
    }
    
    static var person2Examples: [BloodGlucoseData] {
        [BloodGlucoseData(hour: 1, level: 2.5),
         BloodGlucoseData(hour: 2, level: 5.3),
         BloodGlucoseData(hour: 3, level: 4.5),
         BloodGlucoseData(hour: 4, level: 3.5)]
    }
    
}
