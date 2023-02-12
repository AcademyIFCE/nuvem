import CloudKit

@propertyWrapper public class CKReferenceField<Value: CKModel>: CKReferenceFieldProtocol {
    
    public var recordValue: CKRecordValue?
    
    public var storage: FieldStorage
    
    public let key: String
    
    public var referenceForNilRecord: CKRecord.Reference?
    
    public var reference: CKRecord.Reference? { storage.recordValue as? CKRecord.Reference }
    
    var value: Value?

    public var wrappedValue: Value? {
        get {
            return value
        }
        set {
            value = newValue
            storage.recordValue = newValue.map({ CKRecord.Reference(record: $0.record, action: .none) })
        }
    }
    
    public var projectedValue: CKReferenceField<Value> { self }
    
    public init(_ key: String) {
        self.key = key
        self.storage = .init(key: key)
    }
    
    @discardableResult
    public func load(on database: CKDatabase) async throws -> Value? {
        guard let reference else { return nil }
        let record = try await database.record(for: reference.recordID)
        return Value.init(record: record)
    }
    
}
