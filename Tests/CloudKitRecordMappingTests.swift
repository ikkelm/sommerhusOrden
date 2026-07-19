import CloudKit
import XCTest
@testable import sommerhusOrden

final class CloudKitRecordMappingTests: XCTestCase {
    private let zoneID = CKRecordZone.ID(zoneName: "TestZone", ownerName: CKCurrentUserDefaultName)

    // MARK: - Recordnamn

    func testRecordNameRoundTrip() {
        let id = UUID()
        XCTAssertEqual(
            CloudKitRecordMapping.parse(recordName: CloudKitRecordMapping.recordName(forStay: id)),
            .stay(id)
        )
        XCTAssertEqual(
            CloudKitRecordMapping.parse(recordName: CloudKitRecordMapping.recordName(forInventory: id)),
            .inventory(id)
        )
        XCTAssertEqual(
            CloudKitRecordMapping.parse(recordName: CloudKitRecordMapping.recordName(forShopping: id)),
            .shopping(id)
        )
        XCTAssertEqual(
            CloudKitRecordMapping.parse(recordName: CloudKitRecordMapping.settingsRecordName),
            .settings
        )
        XCTAssertNil(CloudKitRecordMapping.parse(recordName: "något-annat"))
    }

    // MARK: - Vistelse

    func testStayRoundTrip() throws {
        let stay = CottageStay(
            familyName: "Familjen Test",
            arrivalDate: Date(timeIntervalSince1970: 1_700_000_000),
            departureDate: Date(timeIntervalSince1970: 1_700_300_000),
            peopleCount: 4,
            bedSpacesNeeded: 5,
            note: "Tar med båten"
        )
        let recordID = CKRecord.ID(
            recordName: CloudKitRecordMapping.recordName(forStay: stay.id),
            zoneID: zoneID
        )
        let record = CKRecord(recordType: CloudKitRecordMapping.stayType, recordID: recordID)
        CloudKitRecordMapping.populate(record, with: stay)

        let decoded = try XCTUnwrap(CloudKitRecordMapping.stay(from: record))
        XCTAssertEqual(decoded, stay)
    }

    // MARK: - Förrådsvara

    func testInventoryItemRoundTrip() throws {
        let item = InventoryItem(
            name: "Oregano",
            category: .pantry,
            status: .low,
            quantityNote: "Nästan tomt"
        )
        let recordID = CKRecord.ID(
            recordName: CloudKitRecordMapping.recordName(forInventory: item.id),
            zoneID: zoneID
        )
        let record = CKRecord(recordType: CloudKitRecordMapping.inventoryType, recordID: recordID)
        CloudKitRecordMapping.populate(record, with: item)

        let decoded = try XCTUnwrap(CloudKitRecordMapping.inventoryItem(from: record))
        XCTAssertEqual(decoded.id, item.id)
        XCTAssertEqual(decoded.name, item.name)
        XCTAssertEqual(decoded.category, item.category)
        XCTAssertEqual(decoded.status, item.status)
        XCTAssertEqual(decoded.quantityNote, item.quantityNote)
    }

    // MARK: - Inköpsrad

    func testShoppingItemRoundTrip() throws {
        let item = ShoppingListItem(
            name: "Mjölk",
            quantityNote: "2 liter",
            category: .fridge,
            isCompleted: true
        )
        let recordID = CKRecord.ID(
            recordName: CloudKitRecordMapping.recordName(forShopping: item.id),
            zoneID: zoneID
        )
        let record = CKRecord(recordType: CloudKitRecordMapping.shoppingType, recordID: recordID)
        CloudKitRecordMapping.populate(record, with: item)

        let decoded = try XCTUnwrap(CloudKitRecordMapping.shoppingItem(from: record))
        XCTAssertEqual(decoded.id, item.id)
        XCTAssertEqual(decoded.name, item.name)
        XCTAssertEqual(decoded.quantityNote, item.quantityNote)
        XCTAssertEqual(decoded.category, item.category)
        XCTAssertTrue(decoded.isCompleted)
    }

    // MARK: - Inställningar

    func testSettingsMerge() {
        var settings = CottageSettings()
        let record = CKRecord(
            recordType: CloudKitRecordMapping.settingsType,
            recordID: CKRecord.ID(recordName: CloudKitRecordMapping.settingsRecordName, zoneID: zoneID)
        )
        record["cottageName"] = "Lillstugan"
        record["maxBedSpaces"] = 8

        settings = CloudKitRecordMapping.settings(from: record, mergingInto: settings)
        XCTAssertEqual(settings.cottageName, "Lillstugan")
        XCTAssertEqual(settings.maxBedSpaces, 8)
    }

    // MARK: - Systemfält

    func testSystemFieldsArchiveRoundTrip() throws {
        let recordID = CKRecord.ID(recordName: "stay-\(UUID().uuidString)", zoneID: zoneID)
        let record = CKRecord(recordType: CloudKitRecordMapping.stayType, recordID: recordID)
        let archived = CloudKitRecordMapping.archiveSystemFields(of: record)

        let restored = try XCTUnwrap(CloudKitRecordMapping.recordFromArchivedSystemFields(archived))
        XCTAssertEqual(restored.recordID, recordID)
        XCTAssertEqual(restored.recordType, CloudKitRecordMapping.stayType)
    }
}
