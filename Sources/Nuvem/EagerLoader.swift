import CloudKit

class EagerLoader<Model: CKModel> {
    
    private(set) var fields = [PartialKeyPath<Model>]()
    
    private(set) var desiredKeys: [String: [CKRecord.FieldKey]] = [:]
    
    func add(_ field: KeyPath<Model, some CKReferenceFieldProtocol>, desiredKeys: [String]?) {
        fields.append(field)
        if let desiredKeys {
            let referenceKey = Model()[keyPath: field].key
            self.desiredKeys[referenceKey, default: []].append(contentsOf: desiredKeys)
        }
    }
    
}
