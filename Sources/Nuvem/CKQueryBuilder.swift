import CloudKit

public class CKQueryBuilder<Model> where Model: CKModel {
    
    let database: CKDatabase
    
    var resultsLimit: Int?
    
    let desiredKeysBuilder = DesiredKeysBuilder<Model>()
    let sortDescriptorsBuilder = SortDescriptorsBuilder<Model>()
    let predicateBuilder = PredicateBuilder<Model>()
    
    var fieldsToEagerLoad = [PartialKeyPath<Model>]()
    
    var eagerLoadDesiredKeys: [String: [CKRecord.FieldKey]] = [:]
    
    init(database: CKDatabase) {
        self.database = database
    }
    
    public func filter(_ predicate: NSPredicate) -> Self {
        predicateBuilder.add(predicate)
        return self
    }
    
    public func filter(_ filter: some CKFilter<Model>) -> Self {
        predicateBuilder.add(filter)
        return self
    }
    
    public func sort(_ field: KeyPath<Model, some CKFieldProtocol>, order: CKSort<Model>.Order = .ascending) -> Self {
        sortDescriptorsBuilder.add(CKSort(field, order: order))
        return self
    }
    
    public func field(_ field: KeyPath<Model, some CKFieldProtocol>) -> Self {
        desiredKeysBuilder.add(field)
        return self
    }
            
    public func field(
        _ f0: KeyPath<Model, some CKFieldProtocol>,
        _ f1: KeyPath<Model, some CKFieldProtocol>
    ) -> Self {
        desiredKeysBuilder.add(f0, f1)
        return self
    }

    public func field(
        _ f0: KeyPath<Model, some CKFieldProtocol>,
        _ f1: KeyPath<Model, some CKFieldProtocol>,
        _ f2: KeyPath<Model, some CKFieldProtocol>
    ) -> Self {
        desiredKeysBuilder.add(f0, f1, f2)
        return self
    }

    public func field(
        _ f0: KeyPath<Model, some CKFieldProtocol>,
        _ f1: KeyPath<Model, some CKFieldProtocol>,
        _ f2: KeyPath<Model, some CKFieldProtocol>,
        _ f3: KeyPath<Model, some CKFieldProtocol>
    ) -> Self {
        desiredKeysBuilder.add(f0, f1, f2, f3)
        return self
    }

    public func field(
        _ f0: KeyPath<Model, some CKFieldProtocol>,
        _ f1: KeyPath<Model, some CKFieldProtocol>,
        _ f2: KeyPath<Model, some CKFieldProtocol>,
        _ f3: KeyPath<Model, some CKFieldProtocol>,
        _ f4: KeyPath<Model, some CKFieldProtocol>
    ) -> Self {
        desiredKeysBuilder.add(f0, f1, f2, f3, f4)
        return self
    }

    public func field(
        _ f0: KeyPath<Model, some CKFieldProtocol>,
        _ f1: KeyPath<Model, some CKFieldProtocol>,
        _ f2: KeyPath<Model, some CKFieldProtocol>,
        _ f3: KeyPath<Model, some CKFieldProtocol>,
        _ f4: KeyPath<Model, some CKFieldProtocol>,
        _ f5: KeyPath<Model, some CKFieldProtocol>
    ) -> Self {
        desiredKeysBuilder.add(f0, f1, f2, f3, f4, f5)
        return self
    }

    public func field(
        _ f0: KeyPath<Model, some CKFieldProtocol>,
        _ f1: KeyPath<Model, some CKFieldProtocol>,
        _ f2: KeyPath<Model, some CKFieldProtocol>,
        _ f3: KeyPath<Model, some CKFieldProtocol>,
        _ f4: KeyPath<Model, some CKFieldProtocol>,
        _ f5: KeyPath<Model, some CKFieldProtocol>,
        _ f6: KeyPath<Model, some CKFieldProtocol>
    ) -> Self {
        desiredKeysBuilder.add(f0, f1, f2, f3, f4, f5, f6)
        return self
    }

    public func field(
        _ f0: KeyPath<Model, some CKFieldProtocol>,
        _ f1: KeyPath<Model, some CKFieldProtocol>,
        _ f2: KeyPath<Model, some CKFieldProtocol>,
        _ f3: KeyPath<Model, some CKFieldProtocol>,
        _ f4: KeyPath<Model, some CKFieldProtocol>,
        _ f5: KeyPath<Model, some CKFieldProtocol>,
        _ f6: KeyPath<Model, some CKFieldProtocol>,
        _ f7: KeyPath<Model, some CKFieldProtocol>
    ) -> Self {
        desiredKeysBuilder.add(f0, f1, f2, f3, f4, f5, f6, f7)
        return self
    }

    public func field(
        _ f0: KeyPath<Model, some CKFieldProtocol>,
        _ f1: KeyPath<Model, some CKFieldProtocol>,
        _ f2: KeyPath<Model, some CKFieldProtocol>,
        _ f3: KeyPath<Model, some CKFieldProtocol>,
        _ f4: KeyPath<Model, some CKFieldProtocol>,
        _ f5: KeyPath<Model, some CKFieldProtocol>,
        _ f6: KeyPath<Model, some CKFieldProtocol>,
        _ f7: KeyPath<Model, some CKFieldProtocol>,
        _ f8: KeyPath<Model, some CKFieldProtocol>
    ) -> Self {
        desiredKeysBuilder.add(f0, f1, f2, f3, f4, f5, f6, f7, f8)
        return self
    }

    public func field(
        _ f0: KeyPath<Model, some CKFieldProtocol>,
        _ f1: KeyPath<Model, some CKFieldProtocol>,
        _ f2: KeyPath<Model, some CKFieldProtocol>,
        _ f3: KeyPath<Model, some CKFieldProtocol>,
        _ f4: KeyPath<Model, some CKFieldProtocol>,
        _ f5: KeyPath<Model, some CKFieldProtocol>,
        _ f6: KeyPath<Model, some CKFieldProtocol>,
        _ f7: KeyPath<Model, some CKFieldProtocol>,
        _ f8: KeyPath<Model, some CKFieldProtocol>,
        _ f9: KeyPath<Model, some CKFieldProtocol>
    ) -> Self {
        desiredKeysBuilder.add(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9)
        return self
    }
    
    public func with<Value>(_ field: KeyPath<Model, CKReferenceField<Value>>) -> Self {
        fieldsToEagerLoad.append(field)
        return self
    }
    
    public func with<Value>(
        _ referenceField: KeyPath<Model, CKReferenceField<Value>>,
        _ field: KeyPath<Value, some CKFieldProtocol>
    ) -> Self {
        fieldsToEagerLoad.append(referenceField)
        let referenceKey = Model()[keyPath: referenceField].key
        eagerLoadDesiredKeys[referenceKey, default: []].append(CKFieldPath(field).key)
        return self
    }
    
    public func with<Value>(
        _ referenceField: KeyPath<Model, CKReferenceField<Value>>,
        _ f0: KeyPath<Value, some CKFieldProtocol>,
        _ f1: KeyPath<Value, some CKFieldProtocol>
    ) -> Self {
        fieldsToEagerLoad.append(referenceField)
        let keys = [f0, f1].map({ CKFieldPath($0).key })
        let referenceKey = Model()[keyPath: referenceField].key
        eagerLoadDesiredKeys[referenceKey, default: []].append(contentsOf: keys)
        return self
    }

    public func with<Value>(
        _ referenceField: KeyPath<Model, CKReferenceField<Value>>,
        _ f0: KeyPath<Value, some CKFieldProtocol>,
        _ f1: KeyPath<Value, some CKFieldProtocol>,
        _ f2: KeyPath<Value, some CKFieldProtocol>
    ) -> Self {
        fieldsToEagerLoad.append(referenceField)
        let keys = [f0, f1, f2].map({ CKFieldPath($0).key })
        let referenceKey = Model()[keyPath: referenceField].key
        eagerLoadDesiredKeys[referenceKey, default: []].append(contentsOf: keys)
        return self
    }

    public func with<Value>(
        _ referenceField: KeyPath<Model, CKReferenceField<Value>>,
        _ f0: KeyPath<Value, some CKFieldProtocol>,
        _ f1: KeyPath<Value, some CKFieldProtocol>,
        _ f2: KeyPath<Value, some CKFieldProtocol>,
        _ f3: KeyPath<Value, some CKFieldProtocol>
    ) -> Self {
        fieldsToEagerLoad.append(referenceField)
        let keys = [f0, f1, f2, f3].map({ CKFieldPath($0).key })
        let referenceKey = Model()[keyPath: referenceField].key
        eagerLoadDesiredKeys[referenceKey, default: []].append(contentsOf: keys)
        return self
    }

    public func with<Value>(
        _ referenceField: KeyPath<Model, CKReferenceField<Value>>,
        _ f0: KeyPath<Value, some CKFieldProtocol>,
        _ f1: KeyPath<Value, some CKFieldProtocol>,
        _ f2: KeyPath<Value, some CKFieldProtocol>,
        _ f3: KeyPath<Value, some CKFieldProtocol>,
        _ f4: KeyPath<Value, some CKFieldProtocol>
    ) -> Self {
        fieldsToEagerLoad.append(referenceField)
        let keys = [f0, f1, f2, f3, f4].map({ CKFieldPath($0).key })
        let referenceKey = Model()[keyPath: referenceField].key
        eagerLoadDesiredKeys[referenceKey, default: []].append(contentsOf: keys)
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
        
        for fieldKeyPath in fieldsToEagerLoad {
            let fields = models.map {
                $0[keyPath: fieldKeyPath] as! (any CKReferenceFieldProtocol)
            }
            let referenceFieldKey = (Model()[keyPath: fieldKeyPath] as! (any CKReferenceFieldProtocol)).key
            let desiredKeys = eagerLoadDesiredKeys[referenceFieldKey]
            try await eagerLoad(fields, desiredKeys: desiredKeys)
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
    
    private func eagerLoad(_ fields: [any CKReferenceFieldProtocol], desiredKeys: [CKRecord.FieldKey]?) async throws {
        
        let idsToFetch = Set(fields.compactMap(\.reference?.recordID))
                
        let response = try await database.records(for: Array(idsToFetch), desiredKeys: desiredKeys)
        
        for field in fields {
            if let id = field.reference?.recordID, let record = try response[id]?.get() {
                field.initialiseValue(record)
            }
        }
        
    }
    
}
