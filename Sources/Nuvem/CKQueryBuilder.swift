import CloudKit

public class CKQueryBuilder<Model> where Model: CKModel {
    
    let database: CKDatabase
    
    var resultsLimit: Int?
    
    var fieldToEagerLoad: PartialKeyPath<Model>?
    
    let desiredKeysBuilder = DesiredKeysBuilder<Model>()
    let sortDescriptorsBuilder = SortDescriptorsBuilder<Model>()
    let predicateBuilder = PredicateBuilder<Model>()
    
    init(database: CKDatabase) {
        self.database = database
    }
    
    public func matching(_ predicate: NSPredicate) -> Self {
        predicateBuilder.add(predicate)
        return self
    }
    
    public func filter(_ filter: some CKFilter<Model>) -> Self {
        predicateBuilder.add(filter)
        return self
    }
    
    public func sort<Value>(_ field: KeyPath<Model, CKField<Value>>, order: CKSort<Model>.Order = .ascending) -> Self {
        sortDescriptorsBuilder.add(CKSort(field, order: order))
        return self
    }
    
    public func field(_ field: KeyPath<Model, some CKFieldProtocol>) -> Self {
        desiredKeysBuilder.add(field)
        return self
    }
    
    public func fields(_ fields: [CKFieldPath<Model>]) -> Self {
        desiredKeysBuilder.add(fields)
        return self
    }
    
    public func with<Value>(_ field: KeyPath<Model, CKReferenceField<Value>>) -> Self {
        fieldToEagerLoad = field
        return self
    }
    
    public func limit(_ limit: Int) -> Self {
        resultsLimit = limit
        return self
    }
    
    public func all() async throws -> [Model] {
        
        var queryCursor: CKQueryOperation.Cursor?
        var matchResults = [(CKRecord.ID, Result<CKRecord, Error>)]()
        
        let response = try await run()
        
        if resultsLimit == nil {
            queryCursor = response.queryCursor
        }
        
        matchResults.append(contentsOf: response.matchResults)
        
        while queryCursor != nil {
            let response = try await database.records(continuingMatchFrom: queryCursor!)
            queryCursor = response.queryCursor
            matchResults.append(contentsOf: response.matchResults)
        }
        
        let models = try matchResults.map { (_, result) in
            let record = try result.get()
            return Model(record: record)
        }
        
        if let fieldToEagerLoad {
            
            let fields = models.map {
                $0[keyPath: fieldToEagerLoad] as! (any CKReferenceFieldProtocol)
            }
            
            try await eagerLoad(fields)
            
        }
        
        return models
        
    }
    
    public func first() async throws -> Model? {
        
        let (matchResults, _) = try await run()
        
        let model = try matchResults.first.map { (_, result) in
            let record = try result.get()
            return Model(record: record)
        }
        
        return model
    }
    
    private func run() async throws -> (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?) {
        
        let predicate = predicateBuilder.predicate
        let sortDescriptors = sortDescriptorsBuilder.sortDescriptors
        let desiredKeys = desiredKeysBuilder.desiredKeys
        
        let query = CKQuery(recordType: Model.recordType, predicate: predicate)
        
        query.sortDescriptors = sortDescriptors
        
        return try await database.records(
            matching: query,
            desiredKeys: desiredKeys,
            resultsLimit: 1
        )
        
    }
    
    private func eagerLoad(_ fields: [any CKReferenceFieldProtocol]) async throws {
        
        let idsToFetch = Set(fields.compactMap(\.reference?.recordID))
        
        let response = try await database.records(for: Array(idsToFetch))
        
        for field in fields {
            if let id = field.reference?.recordID, let record = try response[id]?.get() {
                field.initialiseValue(record)
            }
        }
        
    }
    
}
