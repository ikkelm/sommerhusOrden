import CloudKit
import Foundation

/// Mappning mellan domänmodeller och CKRecord.
/// Recordnamn har typprefix så att raderingar kan tolkas utan extra uppslag.
enum CloudKitRecordMapping {
    static let stayType = "CottageStay"
    static let inventoryType = "InventoryItem"
    static let shoppingType = "ShoppingListItem"
    static let settingsType = "CottageSettings"

    static let settingsRecordName = "cottage-settings"

    // MARK: - Recordnamn

    static func recordName(forStay id: UUID) -> String { "stay-\(id.uuidString)" }
    static func recordName(forInventory id: UUID) -> String { "inv-\(id.uuidString)" }
    static func recordName(forShopping id: UUID) -> String { "shop-\(id.uuidString)" }

    enum ParsedRecordName: Equatable {
        case stay(UUID)
        case inventory(UUID)
        case shopping(UUID)
        case settings
    }

    static func parse(recordName: String) -> ParsedRecordName? {
        if recordName == settingsRecordName { return .settings }
        if recordName.hasPrefix("stay-"), let id = UUID(uuidString: String(recordName.dropFirst(5))) {
            return .stay(id)
        }
        if recordName.hasPrefix("inv-"), let id = UUID(uuidString: String(recordName.dropFirst(4))) {
            return .inventory(id)
        }
        if recordName.hasPrefix("shop-"), let id = UUID(uuidString: String(recordName.dropFirst(5))) {
            return .shopping(id)
        }
        return nil
    }

    // MARK: - Modell -> CKRecord

    static func populate(_ record: CKRecord, with stay: CottageStay) {
        record["familyName"] = stay.familyName
        record["arrivalDate"] = stay.arrivalDate
        record["departureDate"] = stay.departureDate
        record["peopleCount"] = stay.peopleCount
        record["bedSpacesNeeded"] = stay.bedSpacesNeeded
        record["note"] = stay.note
        record["createdAt"] = stay.createdAt
        record["updatedAt"] = stay.updatedAt
    }

    static func populate(_ record: CKRecord, with item: InventoryItem) {
        record["name"] = item.name
        record["category"] = item.category.rawValue
        record["status"] = item.status.rawValue
        record["quantityNote"] = item.quantityNote
        record["createdAt"] = item.createdAt
        record["lastUpdatedAt"] = item.lastUpdatedAt
    }

    static func populate(_ record: CKRecord, with item: ShoppingListItem) {
        record["name"] = item.name
        record["quantityNote"] = item.quantityNote
        record["category"] = item.category?.rawValue
        record["isCompleted"] = item.isCompleted ? 1 : 0
        record["createdAt"] = item.createdAt
        record["updatedAt"] = item.updatedAt
    }

    static func populate(_ record: CKRecord, with settings: CottageSettings) {
        record["cottageName"] = settings.cottageName
        record["maxBedSpaces"] = settings.maxBedSpaces
        record["updatedAt"] = settings.updatedAt
    }

    // MARK: - CKRecord -> Modell

    static func stay(from record: CKRecord) -> CottageStay? {
        guard case .stay(let id) = parse(recordName: record.recordID.recordName),
              let familyName = record["familyName"] as? String,
              let arrivalDate = record["arrivalDate"] as? Date,
              let departureDate = record["departureDate"] as? Date,
              let peopleCount = record["peopleCount"] as? Int
        else { return nil }

        return CottageStay(
            id: id,
            familyName: familyName,
            arrivalDate: arrivalDate,
            departureDate: departureDate,
            peopleCount: peopleCount,
            bedSpacesNeeded: record["bedSpacesNeeded"] as? Int,
            note: record["note"] as? String,
            createdAt: record["createdAt"] as? Date ?? .now,
            updatedAt: record["updatedAt"] as? Date ?? .now
        )
    }

    static func inventoryItem(from record: CKRecord) -> InventoryItem? {
        guard case .inventory(let id) = parse(recordName: record.recordID.recordName),
              let name = record["name"] as? String,
              let categoryRaw = record["category"] as? String,
              let category = InventoryCategory(rawValue: categoryRaw),
              let statusRaw = record["status"] as? String,
              let status = InventoryStatus(rawValue: statusRaw)
        else { return nil }

        return InventoryItem(
            id: id,
            name: name,
            category: category,
            status: status,
            quantityNote: record["quantityNote"] as? String,
            lastUpdatedAt: record["lastUpdatedAt"] as? Date ?? .now,
            createdAt: record["createdAt"] as? Date ?? .now
        )
    }

    static func shoppingItem(from record: CKRecord) -> ShoppingListItem? {
        guard case .shopping(let id) = parse(recordName: record.recordID.recordName),
              let name = record["name"] as? String
        else { return nil }

        let category = (record["category"] as? String).flatMap(InventoryCategory.init(rawValue:))
        return ShoppingListItem(
            id: id,
            name: name,
            quantityNote: record["quantityNote"] as? String,
            category: category,
            isCompleted: (record["isCompleted"] as? Int ?? 0) != 0,
            createdAt: record["createdAt"] as? Date ?? .now,
            updatedAt: record["updatedAt"] as? Date ?? .now
        )
    }

    static func settings(from record: CKRecord, mergingInto existing: CottageSettings) -> CottageSettings {
        var result = existing
        if let name = record["cottageName"] as? String { result.cottageName = name }
        if let max = record["maxBedSpaces"] as? Int { result.maxBedSpaces = max }
        if let updatedAt = record["updatedAt"] as? Date { result.updatedAt = updatedAt }
        return result
    }

    // MARK: - Systemfält

    static func archiveSystemFields(of record: CKRecord) -> Data {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: archiver)
        archiver.finishEncoding()
        return archiver.encodedData
    }

    static func recordFromArchivedSystemFields(_ data: Data) -> CKRecord? {
        guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else { return nil }
        unarchiver.requiresSecureCoding = true
        return CKRecord(coder: unarchiver)
    }
}
