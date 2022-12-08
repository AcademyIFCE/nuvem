import Foundation

public protocol CKFilter<Model> {
    associatedtype Model: CKModel
    var predicate: NSPredicate { get }
}

public struct CKComparisonFilter<Model: CKModel>: CKFilter {
    
    enum Operator: String {
        case isEqualTo = "=="
        case isNotEqualTo = "!="
        case isGreaterThan = ">"
        case isGreaterThanOrEqualTo = ">="
        case isLessThan = "<"
        case isLessThanOrEqualTo = "<="
    }
    
    let key: String
    let value: any CVarArg
    let _operator: Operator
    
    public var predicate: NSPredicate {
        return NSPredicate(format: "\(key) \(_operator.rawValue) %@", value)
    }
    
}

public struct CKLogicFilter<Model: CKModel>: CKFilter {
    
    enum Operator: String {
        case and = "AND"
        case or = "OR"
    }
    
    let filters: [CKComparisonFilter<Model>]
    let _operator: Operator
    
    public var predicate: NSPredicate {
        switch _operator {
            case .and:
                return NSCompoundPredicate(andPredicateWithSubpredicates: filters.map(\.predicate))
            case .or:
                return NSCompoundPredicate(orPredicateWithSubpredicates: filters.map(\.predicate))
        }
    }
    
}

public func == <Model: CKModel, Value>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    let key = Model.init()[keyPath: lhs].key
    let value = rhs
    return CKComparisonFilter(key: key, value: value.attributeValue, _operator: .isEqualTo)
}

public func != <Model: CKModel, Value>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    let key = Model.init()[keyPath: lhs].key
    let value = rhs
    return CKComparisonFilter(key: key, value: value.attributeValue, _operator: .isNotEqualTo)
}

public func && <Model: CKModel>(lhs: CKComparisonFilter<Model>, rhs: CKComparisonFilter<Model>) -> CKLogicFilter<Model> {
    return CKLogicFilter(filters: [lhs, rhs], _operator: .and)
}

public func || <Model: CKModel>(lhs: CKComparisonFilter<Model>, rhs: CKComparisonFilter<Model>) -> CKLogicFilter<Model> {
    return CKLogicFilter(filters: [lhs, rhs], _operator: .or)
}

