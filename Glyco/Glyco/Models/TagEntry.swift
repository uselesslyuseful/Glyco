
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
    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var colorHex: String?
}

extension TagEntry: Identifiable {

    var wrappedID: UUID {
        id ?? UUID()
    }

    var wrappedTitle: String {
        title ?? "Untitled"
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

    var wrappedColorHex: String {
        colorHex ?? "#CCCCCC"
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
    newTag.title = title
    newTag.detail = detail
    newTag.startDate = start
    newTag.endDate = end
    newTag.colorHex = colorHex

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
