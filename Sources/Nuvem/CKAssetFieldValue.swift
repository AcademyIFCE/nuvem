import CloudKit

public protocol CKAssetFieldValue {
    
    static func get(_ value: Data) -> Self
    static func set(_ value: Self) -> Data
    
}

#if canImport(UIKit)

import UIKit

extension UIImage: CKAssetFieldValue {
    
    public static func get(_ value: Data) -> Self {
        return Self(data: value)!
    }
    
    public static func set(_ value: UIImage) -> Data {
        return value.pngData()!
    }
    
}

#endif
