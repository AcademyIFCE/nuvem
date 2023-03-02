import CloudKit

final class FieldStorage {
    
    let key: String?
    
    public var record: CKRecord? {
        didSet {
            guard let key else { return }
            if let recordValue = record?[key] {
                self.recordValue = recordValue
            } else {
                record?[key] = recordValue
            }
        }
    }
    
    var recordValue: CKRecordValue?
    
    var referenceRecord: CKRecord?
            
    init(key: String?) {
        self.key = key
    }
    
    func updateRecord() {
        guard let key else { return }
        record![key] = recordValue
    }
    
    func update(with recordValue: CKRecordValue?) {
        self.recordValue = recordValue
        guard let key else { return }
        record![key] = recordValue
    }
    
}
