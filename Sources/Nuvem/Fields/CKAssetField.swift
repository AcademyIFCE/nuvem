import CloudKit

@propertyWrapper public struct CKAssetField<Value: CKAssetFieldValue>: CKFieldProtocol, _CKFieldProtocol {
    
    public var record: CKRecord? { storage.record }
    
    public var recordValue: CKRecordValue?
    
    var storage: FieldStorage
    
    public let key: String

    var value: Value?

    var defaultValue: Value?

    public var wrappedValue: Value {
        get {
            if let value {
                return value
            }
            else if
                let asset = storage.record?[key] as? CKAsset,
                let url = asset.fileURL,
                let data = FileManager.default.contents(atPath: url.path)
            {
                return Value.get(data)!
            }
            else if let defaultValue {
                return defaultValue
            }
            else {
                fatalError("wrappedValue must be set before access because it has no default value")
            }
        }
        set {
            value = newValue
            if let data = Value.set(newValue) {
                let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                do {
                    try data.write(to: url)
                    storage.recordValue = CKAsset(fileURL: url)
                } catch {
                    print(error)
                    fatalError()
                }
            } else {
                storage.recordValue = nil
            }
        }
    }
    
    public var projectedValue: CKAssetField<Value> { self }
    
    public init(_ key: String, default defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = .init(key: key)
    }

    public init(_ key: String) {
        self.key = key
        self.storage = .init(key: key)
    }

    public init(_ key: String) where Value: ExpressibleByNilLiteral {
        self.key = key
        self.defaultValue = .some(nil)
        self.storage = .init(key: key)
    }
    
}
