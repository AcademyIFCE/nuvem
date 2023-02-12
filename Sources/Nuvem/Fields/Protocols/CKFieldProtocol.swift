import CloudKit

public protocol CKFieldProtocol {
    var key: String { get }
    var recordValue: CKRecordValue? { get }
    var storage: FieldStorage { get }
}

extension CKFieldProtocol {
    
    func updateRecord() {
        storage.recordValue = recordValue
        storage.updateRecord()
    }
    
}
