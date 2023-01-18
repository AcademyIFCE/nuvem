import CloudKit

public protocol FieldStorageProtocol: AnyObject {
    var record: CKRecord? { get set }
}

public class AnyFieldStorage<Value: CKFieldValue>: FieldStorageProtocol {
    
    var key: String
    
    public var record: CKRecord? {
        didSet {
            if oldValue == nil, let record {
                print("updating 'record' with 'value'")
                record[key] = Value.set(value)
            }
        }
    }
    
    var value: Value? {
        didSet {
            record?[key] = Value.set(value)
        }
    }
        
    init(key: String) {
        self.key = key
    }
    
}

public class FieldStorage: FieldStorageProtocol {
    
    var key: String
    
    public var record: CKRecord? {
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
