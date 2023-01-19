import CloudKit

public protocol CKAssetFieldValue {
    
    static func get(_ value: Data) -> Self?
    static func set(_ value: Self?) -> Data?
    
}

extension Optional: CKAssetFieldValue where Wrapped: CKAssetFieldValue {
    
    public static func get(_ value: Data) -> Self? {
        return Wrapped.get(value)
    }
    
    public static func set(_ value: Self?) -> Data? {
        return Wrapped.set(value as? Wrapped)
    }

}

extension Data: CKAssetFieldValue {
    
    public static func get(_ value: Data) -> Data? {
        return value
    }
    
    public static func set(_ value: Data?) -> Data? {
        return value
    }
    
}

#if canImport(UIKit)

import UIKit

extension UIImage: CKAssetFieldValue {
    
    public static func get(_ recordValue: Data) -> Self? {
        return Self(data: recordValue)
    }
    
    public static func set(_ recordValue: UIImage?) -> Data? {
        return recordValue?.pngData()
    }
    
}

#endif
