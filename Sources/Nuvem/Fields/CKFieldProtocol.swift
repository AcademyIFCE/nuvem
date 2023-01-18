public protocol CKFieldProtocol {
//    associatedtype Storage: FieldStorageProtocol
    var key: String { get }
    var storage: FieldStorage { get }
}
