import CloudKit
import Combine

@propertyWrapper public struct CKField<Value: CKFieldValue>: CKFieldProtocol {
    
    public var storage: AnyFieldStorage<Value>
    
    public let key: String
    
    private let defaultValue: Value?
        
    public var value: Value? {
        didSet {
            storage.value = value
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
                fatalError("wrappedValue must be set before access because it has no default value")
            }
        }
        set {
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
