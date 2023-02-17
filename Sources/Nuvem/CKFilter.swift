import Foundation
import CloudKit

public protocol CKFilter<Model> {
    associatedtype Model: CKModel
    var predicate: NSPredicate { get }
}

struct CKPredicateFilter<Model: CKModel>: CKFilter {
    
    let predicate: NSPredicate
    
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
    
    let filters: [any CKFilter]
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

public func == <Model: CKModel, Value: CKFilterableValue>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    let key = Model.init()[keyPath: lhs].key
    let value = rhs
    return CKComparisonFilter(key: key, value: value.attributeValue, _operator: .isEqualTo)
}

public func != <Model: CKModel, Value: CKFilterableValue>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    let key = Model.init()[keyPath: lhs].key
    let value = rhs
    return CKComparisonFilter(key: key, value: value.attributeValue, _operator: .isNotEqualTo)
}

public func > <Model: CKModel, Value: CKFilterableValue>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    let key = Model.init()[keyPath: lhs].key
    let value = rhs
    return CKComparisonFilter(key: key, value: value.attributeValue, _operator: .isGreaterThan)
}

public func >= <Model: CKModel, Value: CKFilterableValue>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    let key = Model.init()[keyPath: lhs].key
    let value = rhs
    return CKComparisonFilter(key: key, value: value.attributeValue, _operator: .isGreaterThanOrEqualTo)
}

public func < <Model: CKModel, Value: CKFilterableValue>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    let key = Model.init()[keyPath: lhs].key
    let value = rhs
    return CKComparisonFilter(key: key, value: value.attributeValue, _operator: .isLessThan)
}

public func <= <Model: CKModel, Value: CKFilterableValue>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    let key = Model.init()[keyPath: lhs].key
    let value = rhs
    return CKComparisonFilter(key: key, value: value.attributeValue, _operator: .isLessThanOrEqualTo)
}

public func == <Model: CKModel, Value: CKModel>(lhs: KeyPath<Model, CKReferenceField<Value>>, rhs: String) -> CKComparisonFilter<Model> {
    let key = Model.init()[keyPath: lhs].key
    let value = CKRecord.ID(recordName: rhs)
    return CKComparisonFilter(key: key, value: value, _operator: .isEqualTo)
}

public func == <Model: CKModel, Value: CKModel>(lhs: KeyPath<Model, CKReferenceField<Value>>, rhs: Value) -> CKComparisonFilter<Model> {
    let key = Model.init()[keyPath: lhs].key
    let value = rhs
    return CKComparisonFilter(key: key, value: value.record.recordID, _operator: .isEqualTo)
}

public func && <Model: CKModel>(lhs: some CKFilter<Model>, rhs: some CKFilter<Model>) -> CKLogicFilter<Model> {
    return CKLogicFilter(filters: [lhs, rhs], _operator: .and)
}

public func || <Model: CKModel>(lhs: some CKFilter<Model>, rhs: some CKFilter<Model>) -> CKLogicFilter<Model> {
    return CKLogicFilter(filters: [lhs, rhs], _operator: .or)
}

extension CKFilter {
    
    static func isDateInToday<Model: CKModel, Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>) -> Self where Value.AttributeValue == Date, Self == CKLogicFilter<Model> {
        return isDate(field, inSameDayAs: .now)
    }
    
    static func isDate<Model: CKModel, Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>, inSameDayAs date: Date) -> Self where Value.AttributeValue == Date, Self == CKLogicFilter<Model> {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1)
        return isDate(field, in: startOfDay...endOfDay)
    }
    
    static func isDate<Model: CKModel, Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>, in range: ClosedRange<Date>) -> Self where Value.AttributeValue == Date, Self == CKLogicFilter<Model> {
        return field >= range.lowerBound && field <= range.upperBound
    }
    
}
