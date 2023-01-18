import CloudKit

//public protocol FieldStorageProtocol: AnyObject {
//    var record: CKRecord? { get set }
//}

//public class FieldStorage<Value: CKFieldValue>: FieldStorageProtocol {
//
//    var key: String
//
//    public var record: CKRecord? {
//        didSet {
//            if let record {
//                print("updating 'record' with 'value'")
//                record[key] = value
////                record[key] = Value.set(value)
//            }
//        }
//    }
//
//    var value: CKRecordValue?
//
//    init(key: String) {
//        self.key = key
//    }
//
//}
//
//public class AssetFieldStorage: FieldStorageProtocol {
//
//    var key: String
//
//    public var record: CKRecord? {
//        didSet {
//            if let record {
//                print("updating 'record' with 'value'")
//                record[key] = asset
//            }
//        }
//    }
//
//    var asset: CKAsset?
//
//    init(key: String) {
//        self.key = key
//    }
//
//}
//
//public class ReferenceFieldStorage: FieldStorageProtocol {
//
//    var key: String
//
//    public var record: CKRecord? {
//        didSet {
//            if let record {
//                print("updating 'record' with 'value'")
//                record[key] = reference
//            }
//        }
//    }
//
//    var reference: CKRecord.Reference?
//
//    init(key: String) {
//        self.key = key
//    }
//
//}

//public class TimestampStorage: FieldStorageProtocol {
//    public var record: CKRecord?
//}

public class FieldStorage {
    
    var key: String?
    
    public var record: CKRecord? {
        didSet {
            print("updating 'record' with 'valueForNilRecord'")
            if let key {
                record![key] = value
            }
        }
    }
    
    var value: CKRecordValue?
    
    init(key: String?) {
        self.key = key
    }
    
}
