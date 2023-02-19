import Foundation

final class PredicateBuilder<Model: CKModel> {
     
    private var filters: [any CKFilter] = []
    
    var predicate: NSPredicate {
        if filters.isEmpty {
            return NSPredicate(value: true)
        } else {
            if filters.count == 1 {
                return filters[0].predicate
            } else {
                return CKLogicFilter<Model>(filters: filters, _operator: .and).predicate
            }
        }
    }
    
    func add(_ filter: some CKFilter<Model>) {
        self.filters.append(filter)
    }
    
}
