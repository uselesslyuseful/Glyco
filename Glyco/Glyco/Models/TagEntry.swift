
//
//  TagEntry.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-04-13.
//

import Foundation
import CoreData

@objc(TagEntry)
public class TagEntry: NSManagedObject {

}

extension TagEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TagEntry> {
        return NSFetchRequest<TagEntry>(entityName: "TagEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var detail: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var tag: Tag?
}

extension TagEntry: Identifiable {

    var wrappedID: UUID {
        id ?? UUID()
    }

    var wrappedDetail: String {
        detail ?? ""
    }

    var wrappedStart: Date {
        startDate ?? Date()
    }

    var wrappedEnd: Date {
        endDate ?? Date()
    }
}

func createTagEntry(
    title: String,
    detail: String?,
    start: Date,
    end: Date,
    colorHex: String,
    context: NSManagedObjectContext
) {
    let newTag = TagEntry(context: context)
    newTag.id = UUID()
    newTag.detail = detail
    newTag.startDate = start
    newTag.endDate = end

    do {
        try context.save()
    } catch {
        print("Error saving tag: \(error)")
    }
}

func fetchTags(for date: Date, context: NSManagedObjectContext) -> [TagEntry] {
    let request = TagEntry.fetchRequest()

    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

    request.predicate = NSPredicate(
        format: "startDate < %@ AND endDate > %@",
        endOfDay as NSDate,
        startOfDay as NSDate
    )

    do {
        return try context.fetch(request)
    } catch {
        print("Fetch error: \(error)")
        return []
    }
}
