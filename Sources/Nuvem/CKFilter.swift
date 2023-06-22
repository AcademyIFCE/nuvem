import Foundation
import CloudKit

public protocol CKFilter<Model> {
    associatedtype Model: CKModel
    var predicate: NSPredicate { get }
}

public struct CKPredicateFilter<Model: CKModel>: CKFilter {
    
    public let predicate: NSPredicate
    
}

public struct CKComparisonFilter<Model: CKModel>: CKFilter {
    
    public enum Operator: String {
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

extension CKComparisonFilter {
    
    public init<Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>, _ `operator`: Operator, _ value: Value.AttributeValue) {
        self.init(key: field.key, value: value.attributeValue, _operator: `operator`)
    }
    
    public init<Value: CKModel>(_ field: KeyPath<Model, CKReferenceField<Value>>, _ `operator`: Operator, _ value: Value) {
        self.init(key: field.key, value: value.record.recordID, _operator: `operator`)
    }
    
    public init<Value: CKModel>(_ field: KeyPath<Model, CKReferenceField<Value>>, _ `operator`: Operator, _ value: String) {
        self.init(key: field.key, value: CKRecord.ID(recordName: value), _operator: `operator`)
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
    return CKComparisonFilter(lhs, .isEqualTo, rhs)
}

public func != <Model: CKModel, Value: CKFilterableValue>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    return CKComparisonFilter(lhs, .isNotEqualTo, rhs)
}

public func > <Model: CKModel, Value: CKFilterableValue>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    return CKComparisonFilter(lhs, .isGreaterThan, rhs)
}

public func >= <Model: CKModel, Value: CKFilterableValue>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    return CKComparisonFilter(lhs, .isGreaterThanOrEqualTo, rhs)
}

public func < <Model: CKModel, Value: CKFilterableValue>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    return CKComparisonFilter(lhs, .isLessThan, rhs)
}

public func <= <Model: CKModel, Value: CKFilterableValue>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value.AttributeValue) -> CKComparisonFilter<Model> {
    return CKComparisonFilter(lhs, .isLessThanOrEqualTo, rhs)
}



public func == <Model: CKModel, Value: CKModel>(lhs: KeyPath<Model, CKReferenceField<Value>>, rhs: Value) -> CKComparisonFilter<Model> {
    return CKComparisonFilter(lhs, .isEqualTo, rhs)
}

public func == <Model: CKModel, Value: CKModel>(lhs: KeyPath<Model, CKReferenceField<Value>>, rhs: Value.ID) -> CKComparisonFilter<Model> where Value.ID == String {
    return CKComparisonFilter(lhs, .isEqualTo, rhs)
}

public func != <Model: CKModel, Value: CKModel>(lhs: KeyPath<Model, CKReferenceField<Value>>, rhs: Value) -> CKComparisonFilter<Model> where Value.ID == String {
    return CKComparisonFilter(lhs, .isNotEqualTo, rhs)
}

public func != <Model: CKModel, Value: CKModel>(lhs: KeyPath<Model, CKReferenceField<Value>>, rhs: Value.ID) -> CKComparisonFilter<Model> where Value.ID == String {
    return CKComparisonFilter(lhs, .isNotEqualTo, rhs)
}



public func == <Model: CKModel, Value: RawRepresentable>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value) -> CKComparisonFilter<Model> where Value.RawValue: AttributeValueProtocol {
    return CKComparisonFilter(key: lhs.key, value: rhs.rawValue.attributeValue, _operator: .isEqualTo)
}

public func != <Model: CKModel, Value: RawRepresentable>(lhs: KeyPath<Model, CKField<Value>>, rhs: Value) -> CKComparisonFilter<Model> where Value.RawValue: AttributeValueProtocol {
    return CKComparisonFilter(key: lhs.key, value: rhs.rawValue.attributeValue, _operator: .isNotEqualTo)
}



public func && <Model: CKModel>(lhs: some CKFilter<Model>, rhs: some CKFilter<Model>) -> CKLogicFilter<Model> {
    return CKLogicFilter(filters: [lhs, rhs], _operator: .and)
}

public func || <Model: CKModel>(lhs: some CKFilter<Model>, rhs: some CKFilter<Model>) -> CKLogicFilter<Model> {
    return CKLogicFilter(filters: [lhs, rhs], _operator: .or)
}




extension CKFilter {
    
    public static func predicate<Model: CKModel>(format: String, _ args: CVarArg...) -> Self where Self == CKPredicateFilter<Model> {
        return CKPredicateFilter(predicate: NSPredicate(format: format, args))
    }
    
}

extension CKFilter {
    
    public static func and<Model: CKModel>(_ filters: [any CKFilter]) -> Self where Self == CKLogicFilter<Model> {
        return CKLogicFilter(filters: filters, _operator: .and)
    }
    
    public static func or<Model: CKModel>(_ filters: [any CKFilter]) -> Self where Self == CKLogicFilter<Model> {
        return CKLogicFilter(filters: filters, _operator: .or)
    }
    
}

extension CKFilter {
    
    public static func isDateInThisYear<Model: CKModel, Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>) -> Self where Value.AttributeValue == Date, Self == CKLogicFilter<Model> {
        return isDate(field, inSameYearAs: .now)
    }

    public static func isDateInThisMonth<Model: CKModel, Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>) -> Self where Value.AttributeValue == Date, Self == CKLogicFilter<Model> {
        return isDate(field, inSameMonthAs: .now)
    }

    public static func isDateInToday<Model: CKModel, Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>) -> Self where Value.AttributeValue == Date, Self == CKLogicFilter<Model> {
        return isDate(field, inSameDayAs: .now)
    }

    public static func isDate<Model: CKModel, Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>, inSameYearAs date: Date) -> Self where Value.AttributeValue == Date, Self == CKLogicFilter<Model> {
        return isDate(field, in: date.bounds(of: .year))
    }

    public static func isDate<Model: CKModel, Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>, inSameMonthAs date: Date) -> Self where Value.AttributeValue == Date, Self == CKLogicFilter<Model> {
        return isDate(field, in: date.bounds(of: .month))
    }

    public static func isDate<Model: CKModel, Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>, inSameDayAs date: Date) -> Self where Value.AttributeValue == Date, Self == CKLogicFilter<Model> {
        return isDate(field, in: date.bounds(of: .day))
    }

    public static func isDate<Model: CKModel, Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>, inSameHourAs date: Date) -> Self where Value.AttributeValue == Date, Self == CKLogicFilter<Model> {
        return isDate(field, in: date.bounds(of: .hour))
    }

    public static func isDate<Model: CKModel, Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>, inSameMinuteAs date: Date) -> Self where Value.AttributeValue == Date, Self == CKLogicFilter<Model> {
        return isDate(field, in: date.bounds(of: .minute))
    }
    
    public static func isDate<Model: CKModel, Value: CKFilterableValue>(_ field: KeyPath<Model, CKField<Value>>, in range: ClosedRange<Date>) -> Self where Value.AttributeValue == Date, Self == CKLogicFilter<Model> {
        return field >= range.lowerBound && field <= range.upperBound
    }
    
}


extension Date {
    
    func bounds(of component: Calendar.Component) -> ClosedRange<Date> {
        
        let components: [Calendar.Component] = [.year, .month, .day, .hour, .minute].prefix(while: { _ in true })
        
        let index = components.firstIndex(of: component)!
        
        let dateComponents = Calendar.current.dateComponents(Set(components.prefix(through: index)), from: self)
        
        let lowerDate = Calendar.current.date(from: dateComponents)!
        let upperDate = Calendar.current.date(byAdding: component, value: 1, to: lowerDate)!.addingTimeInterval(-1)
        
        return lowerDate ... upperDate
        
    }
    
}
