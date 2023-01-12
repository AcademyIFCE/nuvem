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

    public var wrappedValue: Value {
        get {
            if let value {
                return value
            } else {
                guard let asset = record[key] as? CKAsset else { fatalError() }
                guard
                    let url = asset.fileURL,
                    let data = FileManager.default.contents(atPath: url.path)
                else {
                    fatalError()
                }
                value = Value.get(data)
                return value!
            }
        }
        set {
            value = newValue
            let data = Value.set(newValue)
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
        }
    }
    
    public var projectedValue: CKAssetField<Value> { self }
    
    public init(_ key: String) {
        self.key = key
    }
    
}
