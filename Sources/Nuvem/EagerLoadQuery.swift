import CloudKit

struct EagerLoadQuery<Model> {
    
    let fieldKeyPath: PartialKeyPath<Model>
    
    let desiredKeys: [CKRecord.FieldKey]?
        
    init<Value>(field: KeyPath<Model, CKReferenceField<Value>>) {
        self.fieldKeyPath = field
        self.desiredKeys = nil
    }
    
    init<Value>(field: KeyPath<Model, CKReferenceField<Value>>, desiredFields: PartialKeyPath<Value>...) {
        self.fieldKeyPath = field
        self.desiredKeys = desiredFields.map({ CKFieldPath($0).key })
    }
        
    func run(for referenceFields: [any CKReferenceFieldProtocol], on database: CKDatabase) async throws {
        
        let idsToFetch = Set(referenceFields.compactMap(\.reference?.recordID))
                
        let response = try await database.records(for: Array(idsToFetch), desiredKeys: desiredKeys)
        
        for field in referenceFields {
            if let id = field.reference?.recordID, let record = try response[id]?.get() {
                field.storage.record = record
//                field.initialiseValue(record)
            }
        }
        
    }
}
