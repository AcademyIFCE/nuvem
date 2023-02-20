import CloudKit

public struct CKSort<Model: CKModel> {
    
    public enum Order {
        case ascending
        case descending
    }
    
    let key: String
    let order: Order
    
    public var descriptor: NSSortDescriptor {
        NSSortDescriptor(key: key, ascending: order == .ascending ? true : false)
    }
    
}

extension CKSort {
    
    init(_ field: KeyPath<Model, some CKFieldProtocol>, order: Order) {
        self.init(key: field.key, order: order)
    }
    
}
