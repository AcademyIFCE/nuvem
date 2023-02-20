import CloudKit

public protocol CKFieldProtocol {
    var key: String { get }
    var recordValue: CKRecordValue? { get }
    var record: CKRecord? { get }
}

extension KeyPath where Root: CKModel, Value: CKFieldProtocol {
    
    var key: String { Root()[keyPath: self].key }
    
}

extension PartialKeyPath where Root: CKModel {
    
    @_disfavoredOverload
    var key: String { (Root()[keyPath: self] as! any CKFieldProtocol).key }
    
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
