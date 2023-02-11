import CloudKit

public protocol CKFilterableValue {
    
    associatedtype AttributeValue: AttributeValueProtocol = Self
    
}

public protocol AttributeValueProtocol {
    var attributeValue: CVarArg { get }
}

extension Int: CKFilterableValue, AttributeValueProtocol {
    public var attributeValue: CVarArg {
        NSNumber(value: self)
    }
}

extension Double: CKFilterableValue, AttributeValueProtocol {
    public var attributeValue: CVarArg {
        self
    }
}

extension String: CKFilterableValue, AttributeValueProtocol {
    public var attributeValue: CVarArg {
        self
    }
}

extension Bool: CKFilterableValue, AttributeValueProtocol {
    public var attributeValue: CVarArg {
        NSNumber(booleanLiteral: self)
    }
}

extension Date: CKFilterableValue, AttributeValueProtocol {
    public var attributeValue: CVarArg {
        self as NSDate
    }
}

extension Optional: CKFilterableValue where Wrapped: CKFilterableValue & AttributeValueProtocol {
    
    public typealias AttributeValue = Wrapped
    
}
