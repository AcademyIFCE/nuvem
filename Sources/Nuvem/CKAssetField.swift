import CloudKit

@propertyWrapper public struct CKAssetField<Value: CKAssetFieldValue>: CKFieldProtocol {
    
    public var storage: Storage
    
    public let key: String

    private var assetForNilRecord: CKAsset?

    var asset: CKAsset? {
        get {
            storage.record?[key] as? CKAsset
        }
        set {
            storage.record?[key] = newValue
        }
    }

    var value: Value?

    var defaultValue: Value?

    public var wrappedValue: Value {
        get {
            if let value {
                return value
            } else if let asset = storage.record?[key] as? CKAsset, let url = asset.fileURL, let data = FileManager.default.contents(atPath: url.path) {
                return Value.get(data)!
            } else if let defaultValue {
                return defaultValue
            } else {
                fatalError("wrappedValue must be set before access because it has no default value")
            }
        }
        set {
            value = newValue
            if let data = Value.set(newValue) {
                let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                do {
                    try data.write(to: url)
                    if let record = storage.record {
                        record[key] = CKAsset(fileURL: url)
                    } else {
                        assetForNilRecord = CKAsset(fileURL: url)
                        storage.valueForNilRecord = assetForNilRecord
                    }
                } catch {
                    print(error)
                    fatalError()
                }
            } else {
                if let record = storage.record {
                    record[key] = nil
                } else {
                    assetForNilRecord = nil
                }
            }
        }
    }
    
    public var projectedValue: CKAssetField<Value> { self }
    
    public init(_ key: String, default defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = Storage(key: key)
    }

    public init(_ key: String) {
        self.key = key
        self.storage = Storage(key: key)
    }
    
}
