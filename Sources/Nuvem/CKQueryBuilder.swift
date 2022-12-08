import CloudKit

public class CKQueryBuilder<Model> where Model: CKModel {
    
    let database: CKDatabase
    var resultsLimit: Int?
    var predicate: NSPredicate
    var sortDescriptors: [NSSortDescriptor]
    var desiredKeys: [CKRecord.FieldKey]?
    var keyPathOfFieldToEagerLoad: PartialKeyPath<Model>?
    
    init(database: CKDatabase) {
        self.database = database
        self.predicate = NSPredicate(value: true)
        self.sortDescriptors = []
    }
    
    public func filter(_ filter: some CKFilter<Model>) -> Self {
        self.predicate = filter.predicate
        return self
    }
    
    public func sort<Value>(_ field: KeyPath<Model, CKField<Value>>, order: CKSort<Model>.Order = .ascending) -> Self {
        self.sortDescriptors.append(CKSort(field, order: order).descriptor)
        return self
    }
    
    public func field(_ field: KeyPath<Model, some CKFieldProtocol>) -> Self {
        let key = Model.init()[keyPath: field].key
        if desiredKeys == nil {
            desiredKeys = []
        }
        desiredKeys?.append(key)
        return self
    }
    
    public func with<Value>(_ field: KeyPath<Model, CKReferenceField<Value>>) -> Self {
        keyPathOfFieldToEagerLoad = field
        return self
    }
    
    public func limit(_ limit: Int) -> Self {
        self.resultsLimit = limit
        return self
    }
    
    public func all() async throws -> [Model] {
        return try await matching(predicate)
    }
    
    func first() async throws -> Model? {
        
        let query = CKQuery(recordType: Model.recordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        
        let (matchResults, _) = try await database.records(matching: query, resultsLimit: 1)
        
        let model = try matchResults.first.map { (_, result) in
            let record = try result.get()
            return Model(record: record)
        }
        
        return model
    }
    
    public func matching(_ predicate: NSPredicate) async throws -> [Model] {
        
        let query = CKQuery(recordType: Model.recordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors
                
        var cursor: CKQueryOperation.Cursor?
        var matchResults = [(CKRecord.ID, Result<CKRecord, Error>)]()
        
        let response = try await database.records(
            matching: query,
            desiredKeys: desiredKeys,
            resultsLimit: resultsLimit ?? CKQueryOperation.maximumResults
        )
        
        if resultsLimit == nil {
            cursor = response.queryCursor
        }
        
        matchResults.append(contentsOf: response.matchResults)
        
        while cursor != nil {
            let response = try await database.records(continuingMatchFrom: cursor!)
            cursor = response.queryCursor
            matchResults.append(contentsOf: response.matchResults)
        }
        
        let models = try matchResults.map { (_, result) in
            let record = try result.get()
            return Model(record: record)
        }
        
        if let keyPathOfFieldToEagerLoad {
            
            var idsToFetch: Set<CKRecord.ID> = []
            
            var fields: [any CKReferenceFieldProtocol] = []
            
            for model in models {
                let field = model[keyPath: keyPathOfFieldToEagerLoad] as! (any CKReferenceFieldProtocol)
                if let id = field.reference?.recordID {
                    fields.append(field)
                    idsToFetch.insert(id)
                }
            }
            
            let response = try await database.records(for: Array(idsToFetch))
            
            for field in fields {
                if let id = field.reference?.recordID, let record = try response[id]?.get() {
                    field.initialiseValue(record)
                }
            }
                        
        }
        
        return models
        
    }
    
}
