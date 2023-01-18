import CloudKit

protocol CKReferenceFieldProtocol: CKFieldProtocol, AnyObject {
    associatedtype Value: CKModel
    var reference: CKRecord.Reference? { get set }
    var value: Value? { get set }
}

extension CKReferenceFieldProtocol {
    
    func initialiseValue(_ record: CKRecord) {
        value = .init(record: record)
    }
    
}
