import CloudKit
import SwiftUI

public protocol CKModel: Identifiable {
    static var recordType: CKRecord.RecordType { get }
    var record: CKRecord! { get set }
    init()
}

extension CKModel {
    
    subscript(checkedMirrorDescendant key: String) -> Any {
        return Mirror(reflecting: self).descendant(key)!
    }
    
    var allKeyPaths: [String: PartialKeyPath<Self>] {
        var allKeyPaths = [String: PartialKeyPath<Self>]()
        let mirror = Mirror(reflecting: self)
        for case (let key?, _) in mirror.children {
            allKeyPaths[key] = \Self.[checkedMirrorDescendant: key] as PartialKeyPath
        }
        return allKeyPaths
    }
    
    func bindRecordToFields() {
        
        let allKeyPaths = allKeyPaths.values
        
        let allFields = allKeyPaths.compactMap({ self[keyPath: $0] as? (any CKFieldProtocol) })

        for field in allFields {
            if field.storage.record != nil {
                field.storage.updateRecord()
            } else {
                field.storage.record = self.record
            }
        }
        
    }
    
}

extension CKModel {
    
    public static var recordType: CKRecord.RecordType { String(describing: Self.self) }
    
    public var id: String { record.recordID.recordName }
    
    public var modificationDate: Date? { record.modificationDate }
    
    public var creationDate: Date? { record.creationDate }
    
    init(record: CKRecord) {
        self.init()
        self.record = record
        bindRecordToFields()
    }
    
}

extension CKModel {
    
    public static func find(id: CKRecord.ID, on database: CKDatabase) async throws -> Self {
        let record = try await database.record(for: id)
        let model = Self(record: record)
        return model
    }
    
    public static func query(on database: CKDatabase) -> CKQueryBuilder<Self> {
        return CKQueryBuilder(database: database)
    }
    
    public static func fields(fields: PartialKeyPath<Self>...) async throws {
        fatalError()
    }
    
    public mutating func save(on database: CKDatabase) async throws {
        if record == nil {
            record = CKRecord(recordType: Self.recordType)
        }
        bindRecordToFields()
        self.record = try await database.save(record)
    }
    
    public func delete(on database: CKDatabase) async throws {
        try await database.deleteRecord(withID: record.recordID)
    }
    
}

extension Binding where Value: CKModel {
    
    public func save(on database: CKDatabase) async throws {
        try await wrappedValue.save(on: database)
    }
    
}
