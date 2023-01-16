import CloudKit
import Combine

public protocol CKFieldProtocol: AnyObject {
    var key: String { get }
    var record: CKRecord! { get set }
}

@propertyWrapper public class CKField<Value: CKFieldValue>: CKFieldProtocol {
    
    public let key: String
    
    public var record: CKRecord! {
        didSet {
            if oldValue == nil, let valueForNilRecord {
                print("updating 'record' with 'valueForNilRecord'")
                record![key] = Value.set(valueForNilRecord)
            }
        }
    }
    
    private let defaultValue: Value?
    
    private var valueForNilRecord: Value?
    
    public var value: Value? {
        Value.get(record![key])
    }

    public var wrappedValue: Value {
        get {
            if let record, let recordValue = Value.get(record[key]) {
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
            if let record {
                record[key] = Value.set(newValue)
            } else {
                valueForNilRecord = newValue
            }
        }
    }
    
    public var projectedValue: CKField<Value> { self }
    
    public lazy var publisher = PassthroughSubject<Value, Never>()
    
    public init(_ key: String, default defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public init(_ key: String) {
        self.key = key
        self.defaultValue = nil
    }
    
    func load(on database: CKDatabase) async throws -> Value? {
        let id = record.recordID
        guard let result = try await database.records(for: [id], desiredKeys: [key])[id] else {
            return nil
        }
        self.record[key] = try result.get()[key]
        return wrappedValue
    }
    
}
