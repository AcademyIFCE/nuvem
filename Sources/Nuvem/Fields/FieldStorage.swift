import CloudKit

public class FieldStorage {
    
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
