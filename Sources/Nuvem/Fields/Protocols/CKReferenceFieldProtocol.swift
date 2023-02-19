import CloudKit

protocol CKReferenceFieldProtocol: CKFieldProtocol, _CKFieldProtocol {
    var reference: CKRecord.Reference? { get }
//    var value: Value? { get set }
}

//extension CKReferenceFieldProtocol {
//    
//    func initialiseValue(_ record: CKRecord) {
//        value = .init(record: record)
//    }
//    
//}
