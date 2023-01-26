import CloudKit

public class FieldStorage {
    
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
            
    init(key: String?) {
        self.key = key
    }
    
    func updateRecord() {
        guard let key else { return } 
        record![key] = recordValue
    }
    
}
