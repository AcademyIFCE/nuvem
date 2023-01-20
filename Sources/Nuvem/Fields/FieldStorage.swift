import CloudKit

public class FieldStorage {
    
    let key: String
    
    public var record: CKRecord? {
        didSet {
            if let recordValue = record?[key] {
                self.recordValue = recordValue
            } else {
                record?[key] = recordValue
            }
        }
    }
    
    var recordValue: CKRecordValue?
            
    init(key: String) {
        self.key = key
    }
    
    func updateRecord() {
        record![key] = recordValue
    }
    
}
