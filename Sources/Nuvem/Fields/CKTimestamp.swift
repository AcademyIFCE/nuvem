import CloudKit

@propertyWrapper public struct CKTimestamp: CKFieldProtocol {
    
    public var storage: FieldStorage
    
    public enum Event: String {
        case creation = "creationDate"
        case modification = "modificationDate"
    }
    
//    public var record: CKRecord!
    
    public var key: String {
        event.rawValue
    }
    
    private var event: Event

    public var wrappedValue: Date? {
        switch event {
            case .creation:
                return storage.record?.creationDate
            case .modification:
                return storage.record?.modificationDate
        }
    }
    
    public var projectedValue: CKTimestamp { self }
    
    public init(_ event: Event) {
        self.event = event
        self.storage = FieldStorage(key: event.rawValue)
    }
    
}
