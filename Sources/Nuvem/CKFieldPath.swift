import CloudKit

public struct CKFieldPath<Model: CKModel> {
   
    private let fieldKeyPath: PartialKeyPath<Model>
    
    var key: String {
        (Model.init()[keyPath: fieldKeyPath] as! any CKFieldProtocol).key
    }
    
    init(_ field: PartialKeyPath<Model>) {
        self.fieldKeyPath = field
    }
    
//    public init(_ field: KeyPath<Model, some CKFieldProtocol>) {
//        self.fieldKeyPath = field
//    }
    
}

//prefix operator *
//
//prefix public func * <Model: CKModel>(field: KeyPath<Model, some CKFieldProtocol>) -> CKFieldPath<Model> {
//    return CKFieldPath(field)
//}
