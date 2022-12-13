import CloudKit

@propertyWrapper public class CKAssetField<Value: CKAssetFieldValue> {
    
    public let key: String
    
    public var record: CKRecord!
    
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
                record[key] = CKAsset(fileURL: url)
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
