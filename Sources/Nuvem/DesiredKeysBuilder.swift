import CloudKit

final class DesiredKeysBuilder<Model: CKModel> {
    
    var fields: [CKFieldPath<Model>] = []
    
    var desiredKeys: [CKRecord.FieldKey]? {
        guard !fields.isEmpty else {
            return nil
        }
        return fields.map(\.key)
    }
    
    func add(_ fields: [CKFieldPath<Model>]) {
        self.fields.append(contentsOf: fields)
    }
    
    func add(_ field: KeyPath<Model, some CKFieldProtocol>) {
        self.fields.append(CKFieldPath(field))
    }
    
}
