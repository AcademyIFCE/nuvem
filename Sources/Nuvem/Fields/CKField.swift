import CloudKit
import Combine

@propertyWrapper public struct CKField<Value: CKFieldValue>: CKFieldProtocol, _CKFieldProtocol {
    
    var hasBeenSet: Bool = false
    
    public var record: CKRecord? { storage.record }
    
    public let key: String
    
    public var recordValue: CKRecordValue?
    
    var storage: FieldStorage
    
    private let defaultValue: Value?
        
    private(set) var value: Value? {
        didSet {
            recordValue = Value.set(value)
//            storage.recordValue = recordValue
        }
    }
    
    public var wrappedValue: Value {
        get {
            if let value {
                return value
            }
            else if let record = storage.record, let recordValue = Value.get(record[key]) {
                return recordValue
            }
            else if let defaultValue {
                return defaultValue
            }
            else {
                print("key = \(key)")
                fatalError("wrappedValue must be set before access because it has no default value")
            }
        }
        set {
            hasBeenSet = true
            value = newValue
            publisher.send(newValue)
        }
    }
    
    public var projectedValue: CKField<Value> { self }
    
    public lazy var publisher = PassthroughSubject<Value, Never>()
    
    public init(_ key: String, default defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = .init(key: key)
    }
    
    public init(_ key: String) {
        self.key = key
        self.defaultValue = nil
        self.storage = .init(key: key)
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
