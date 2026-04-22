import Foundation
import CoreData

@objc(Tag)
public class Tag: NSManagedObject {}

extension Tag {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var entries: Set<TagEntry>?
}

extension Tag: Identifiable {
    var wrappedID: UUID { id ?? UUID() }
    var wrappedTitle: String { title ?? "Untitled" }
    var wrappedColorHex: String { colorHex ?? "#CCCCCC" }
}
