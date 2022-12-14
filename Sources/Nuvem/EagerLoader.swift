import CloudKit

class EagerLoader<Model: CKModel> {
    
    private(set) var fields = [PartialKeyPath<Model>]()
    
    private(set) var desiredKeys: [String: [CKRecord.FieldKey]] = [:]
    
    func add(_ field: KeyPath<Model, some CKReferenceFieldProtocol>) {
        fields.append(field)
    }
    
    func add<Value>(_ field: KeyPath<Model, CKReferenceField<Value>>, desiredFields: PartialKeyPath<Value>...) {
        fields.append(field)
        let referenceKey = Model()[keyPath: field].key
        self.desiredKeys[referenceKey, default: []].append(contentsOf: desiredFields.map({ CKFieldPath($0).key }))
    }
    
}
