# Nuvem

## Declaring Models

```swift

struct User: CKModel {
    
    var record: CKRecord!
    
    @CKField("name")
    var name: String
    
    init() { }
    
}

struct Todo: CKModel {
    
    var record: CKRecord!
    
    @CKTimestamp(.creation)
    var creationDate: Date?
    
    @CKTimestamp(.modification)
    var modificationDate: Date?
    
    @CKField("text")
    var text: String
    
    @CKField("tags", default: [])
    var tags: [String]
    
    @CKField("isCompleted")
    var isCompleted: Bool
    
    @CKReferenceField("user")
    var user: User?
    
    init() { }
    
}

```

## Saving

```swift

try await todo.save(on: <#CKDatabase#>)

```

## Deleting

```swift

try await todo.delete(on: <#CKDatabase#>)

```

## Querying

```swift

try await Todo.query(on: <#CKDatabase#>).all()

try await Todo.query(on: <#CKDatabase#>).first()

try await Todo.query(on: <#CKDatabase#>).limit(10)

```

### Filtering

```swift

try await Todo.query(on: <#CKDatabase#>).filter(\.$isCompleted == true).all()

```

### Sorting

```swift

try await Todo.query(on: <#CKDatabase#>).sort(\.$modificationDate, order: .descending).all()

```

### Specifying Desired Fields

```swift

try await Todo.query(on: <#CKDatabase#>).field(\.$text, \.$isCompleted, \.$user).all()

```

### Eager Loading Reference

```swift

try await Todo.query(on: <#CKDatabase#>).with(\.$user).all()

```

### Putting It All Together

```swift

let todos = try await Todo.query(on: <#CKDatabase#>)
    .filter(\.$isCompleted == true)
    .sort(\.$modificationDate, order: .descending)
    .field(\.$text, \.$isCompleted, \.$user)
    .with(\.$user)
    .all()

```
