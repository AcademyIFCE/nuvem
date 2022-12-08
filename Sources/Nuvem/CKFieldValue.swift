import CloudKit

public protocol CKFieldValue {
    
    associatedtype AttributeValue: AttributeValueProtocol = Self
    
    static func get(_ value: CKRecordValue?) -> Self?
    static func set(_ value: Self?) -> CKRecordValue?
    
}

public protocol AttributeValueProtocol {
    var attributeValue: CVarArg { get }
}

extension CKFieldValue where Self: CKRecordValueProtocol {
    
    public static func get(_ value: CKRecordValue?) -> Self? {
        return value as? Self
    }
    
    public static func set(_ value: Self?) -> CKRecordValue? {
        return value as? CKRecordValue
    }
    
}

extension CKFieldValue where Self: RawRepresentable {
    
    public static func get(_ value: CKRecordValue?) -> Self? {
        if let rawValue = value as? RawValue {
            return Self(rawValue: rawValue)
        } else {
            return nil
        }
    }
    
    public static func set(_ value: Self?) -> CKRecordValue? {
        return value?.rawValue as? CKRecordValue
    }
    
}

extension Int: CKFieldValue, AttributeValueProtocol {
    public var attributeValue: CVarArg {
        self
    }
}

extension Double: CKFieldValue, AttributeValueProtocol {
    public var attributeValue: CVarArg {
        self
    }
}

extension String: CKFieldValue, AttributeValueProtocol {
    public var attributeValue: CVarArg {
        self
    }
}

extension Bool: CKFieldValue, AttributeValueProtocol {
    public var attributeValue: CVarArg {
        NSNumber(booleanLiteral: self)
    }
}

extension Date: CKFieldValue, AttributeValueProtocol {
    public var attributeValue: CVarArg {
        self as NSDate
    }
}

extension Optional: CKFieldValue where Wrapped: CKFieldValue & AttributeValueProtocol {
    
    public typealias AttributeValue = Wrapped
    
    public static func get(_ value: CKRecordValue?) -> Self? {
        return Wrapped.get(value)
    }
    
    public static func set(_ value: Self?) -> CKRecordValue? {
        return Wrapped.set(value!)
    }
    
}

extension Array: CKFieldValue & AttributeValueProtocol where Element: CKRecordValueProtocol {
    
    public static func get(_ value: CKRecordValue?) -> Self? {
        return value as? Self
    }
    
    public static func set(_ value: Self?) -> CKRecordValue? {
        return value as? CKRecordValue
    }
    
    public var attributeValue: CVarArg {
        fatalError()
    }
    
}
