import CloudKit

@propertyWrapper public struct CKReferenceField<Value: CKModel>: CKReferenceFieldProtocol {
    
    public var storage: FieldStorage
    
    public let key: String
    
//    public var record: CKRecord! {
//        didSet {
//            if oldValue == nil, let referenceForNilRecord {
//                print("updating 'record' with 'referenceForNilRecord'")
//                record![key] = referenceForNilRecord
//            }
//        }
//    }
    
    public var referenceForNilRecord: CKRecord.Reference?
    
    public var reference: CKRecord.Reference? {
        get {
            storage.record?[key] as? CKRecord.Reference
        }
        set {
            storage.record?[key] = newValue
        }
    }
    
    var value: Value?

    public var wrappedValue: Value? {
        get {
            return value
        }
        set {
            value = newValue
            if storage.record != nil {
                reference = newValue.map({ CKRecord.Reference(record: $0.record, action: .none) })
            } else {
                referenceForNilRecord = newValue.map({ CKRecord.Reference(record: $0.record, action: .none) })
                storage.valueForNilRecord = referenceForNilRecord
            }
        }
    }
    
    public var projectedValue: CKReferenceField<Value> { self }
    
    public init(_ key: String) {
        self.key = key
        self.storage = FieldStorage(key: key)
    }
    
    @discardableResult
    public func load(on database: CKDatabase) async throws -> Value? {
        guard let reference else { return nil }
        let record = try await database.record(for: reference.recordID)
        return Value.init(record: record)
    }
    
}
