import CloudKit
import Combine

public class Storage {
    
    var key: String
    
    var record: CKRecord? {
        didSet {
            if oldValue == nil, let valueForNilRecord {
                print("updating 'record' with 'valueForNilRecord'")
                record![key] = valueForNilRecord
            }
        }
    }
    
    var valueForNilRecord: CKRecordValue?
    
    init(key: String) {
        self.key = key
    }
    
}

public protocol CKFieldProtocol {
    var key: String { get }
    var storage: Storage { get }
}

@propertyWrapper public struct CKField<Value: CKFieldValue>: CKFieldProtocol {
    
    public var storage: Storage
    
    public let key: String
    
    private let defaultValue: Value?
    
    private var valueForNilRecord: Value?
    
    public var value: Value? {
        if let record = storage.record {
            return Value.get(record[key])
        } else {
            return nil
        }
        
    }
    
    public var wrappedValue: Value {
        get {
            if let record = storage.record, let recordValue = Value.get(record[key]) {
                return recordValue
            }
            else if let valueForNilRecord {
                return valueForNilRecord
            }
            else if let defaultValue {
                return defaultValue
            }
            else {
                fatalError("wrappedValue must be set before access because it has no default value")
            }
        }
        set {
            publisher.send(newValue)
            if let record = storage.record {
                record[key] = Value.set(newValue)
            } else {
                valueForNilRecord = newValue
                storage.valueForNilRecord = Value.set(newValue)
            }
        }
    }
    
    public var projectedValue: CKField<Value> { self }
    
    public lazy var publisher = PassthroughSubject<Value, Never>()
    
    public init(_ key: String, default defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = Storage(key: key)
    }
    
    public init(_ key: String) {
        self.key = key
        self.defaultValue = nil
        self.storage = Storage(key: key)
    }
    
    func load(on database: CKDatabase) async throws -> Value? {
        guard let record = storage.record else { return nil }
        let id = record.recordID
        guard let result = try await database.records(for: [id], desiredKeys: [key])[id] else {
            return nil
        }
        record[key] = try result.get()[key]
        return wrappedValue
    }
    
}
