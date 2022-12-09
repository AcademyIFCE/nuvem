import Foundation

final class PredicateBuilder<Model: CKModel> {
     
    private var filter: (any CKFilter)?
    
    var predicate: NSPredicate {
        if let filter {
            return filter.predicate
        } else {
            return NSPredicate(value: true)
        }
    }
    
    func add(_ filter: some CKFilter<Model>) {
        self.filter = filter
    }
    
    func add(_ predicate: NSPredicate) {
        self.filter = CKPredicateFilter<Model>(predicate: predicate)
    }
    
}
