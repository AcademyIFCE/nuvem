import CloudKit

@propertyWrapper public class CKAssetField<Value: CKAssetFieldValue>: CKFieldProtocol {
    
    public let key: String
    
    public var record: CKRecord! {
        didSet {
            if oldValue == nil, let assetForNilRecord {
                print("updating 'record' with 'assetForNilRecord'")
                record![key] = assetForNilRecord
            }
        }
    }

    private var assetForNilRecord: CKAsset?

    var asset: CKAsset? {
        get {
            record[key] as? CKAsset
        }
        set {
            record[key] = newValue
        }
    }

    var value: Value?

    var defaultValue: Value?

    public var wrappedValue: Value {
        get {
            if let value {
                return value
            } else if let asset = record[key] as? CKAsset, let url = asset.fileURL, let data = FileManager.default.contents(atPath: url.path) {
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
                    if let record {
                        record[key] = CKAsset(fileURL: url)
                    } else {
                        assetForNilRecord = CKAsset(fileURL: url)
                    }
                } catch {
                    print(error)
                    fatalError()
                }
            } else {
                if let record {
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
    }

    public init(_ key: String) {
        self.key = key
    }
    
}
