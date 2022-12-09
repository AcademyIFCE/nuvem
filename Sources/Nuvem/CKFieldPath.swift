import CloudKit

public struct CKFieldPath<Model: CKModel> {
   
    private let fieldKeyPath: PartialKeyPath<Model>
    
    var key: String {
        (Model.init()[keyPath: fieldKeyPath] as! any CKFieldProtocol).key
    }
    
    public init(_ field: KeyPath<Model, some CKFieldProtocol>) {
        self.fieldKeyPath = field
    }
    
}
