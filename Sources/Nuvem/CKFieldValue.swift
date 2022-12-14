import CloudKit

public protocol CKFieldValue {
        
    static func get(_ value: CKRecordValue?) -> Self?
    static func set(_ value: Self?) -> CKRecordValue?
    
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

extension Int: CKFieldValue { }

extension Double: CKFieldValue { }

extension String: CKFieldValue { }

extension Bool: CKFieldValue { }

extension Date: CKFieldValue { }

extension Optional: CKFieldValue where Wrapped: CKFieldValue {

    public static func get(_ value: CKRecordValue?) -> Self? {
        return Wrapped.get(value)
    }

    public static func set(_ value: Self?) -> CKRecordValue? {
        return Wrapped.set(value!)
    }

}

extension Array: CKFieldValue where Element: CKRecordValueProtocol {
    
    public static func get(_ value: CKRecordValue?) -> Self? {
        return value as? Self
    }
    
    public static func set(_ value: Self?) -> CKRecordValue? {
        return value as? CKRecordValue
    }
    
}
