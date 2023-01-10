import CloudKit

protocol CKReferenceFieldProtocol: CKFieldProtocol {
    associatedtype Value: CKModel
    var reference: CKRecord.Reference? { get set }
    var value: Value? { get set }
}

extension CKReferenceFieldProtocol {
    
    func initialiseValue(_ record: CKRecord) {
        value = .init(record: record)
    }
    
}

@propertyWrapper public class CKReferenceField<Value: CKModel>: CKReferenceFieldProtocol {
    
    public let key: String
    
    public var record: CKRecord! {
        didSet {
            if oldValue == nil, let referenceForNilRecord {
                print("updating 'record' with 'referenceForNilRecord'")
                record![key] = referenceForNilRecord
            }
        }
    }
    
    public var referenceForNilRecord: CKRecord.Reference?
    
    public var reference: CKRecord.Reference? {
        get {
            record[key] as? CKRecord.Reference
        }
        set {
            record[key] = newValue
        }
    }
    
    var value: Value?

    public var wrappedValue: Value? {
        get {
            return value
        }
        set {
            value = newValue
            if record != nil {
                reference = newValue.map({ CKRecord.Reference(record: $0.record, action: .none) })
            } else {
                referenceForNilRecord = newValue.map({ CKRecord.Reference(record: $0.record, action: .none) })
            }
        }
    }
    
    public var projectedValue: CKReferenceField<Value> { self }
    
    public init(_ key: String) {
        self.key = key
    }
    
    @discardableResult
    public func load(on database: CKDatabase) async throws -> Value? {
        guard let reference else { return nil }
        let record = try await database.record(for: reference.recordID)
        return Value.init(record: record)
    }
    
}
