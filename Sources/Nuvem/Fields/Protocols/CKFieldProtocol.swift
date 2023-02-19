import CloudKit

public protocol CKFieldProtocol {
    var key: String { get }
    var recordValue: CKRecordValue? { get }
    var record: CKRecord? { get }
}

extension KeyPath where Root: CKModel, Value: CKFieldProtocol {
    
    var key: String { Root()[keyPath: self].key }
    
}

protocol _CKFieldProtocol: CKFieldProtocol {
    var storage: FieldStorage { get }
}


extension _CKFieldProtocol {
    
    func updateRecord() {
        storage.recordValue = recordValue
        storage.updateRecord()
    }
    
}
