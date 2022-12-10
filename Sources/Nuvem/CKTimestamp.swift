import CloudKit

@propertyWrapper public class CKTimestamp {
    
    public enum Event: String {
        case creation = "creationDate"
        case modification = "modificationDate"
    }
    
    public var record: CKRecord!
    
    public var event: Event

    public var wrappedValue: Date? {
        switch event {
            case .creation:
                return record.creationDate
            case .modification:
                return record.modificationDate
        }
    }
    
    public init(_ event: Event) {
        self.event = event
    }
    
}
