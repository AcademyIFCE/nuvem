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
    
    init<Value>(_ keyPath: KeyPath<Model, CKField<Value>>, order: Order) {
        let key = Model.init()[keyPath: keyPath].key
        self.init(key: key, order: order)
    }
    
}

extension CKSort {
    
    init(_ keyPath: KeyPath<Model, CKTimestamp>, order: Order) {
        let key = Model.init()[keyPath: keyPath].event.rawValue
        self.init(key: key, order: order)
    }
    
}
