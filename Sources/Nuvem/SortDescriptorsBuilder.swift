import Foundation

final class SortDescriptorsBuilder<Model: CKModel> {
    
    var sorts: [CKSort<Model>] = []
    
    var sortDescriptors: [NSSortDescriptor] {
        return sorts.map(\.descriptor)
    }
    
    func add(_ sort: CKSort<Model>) {
        sorts.append(sort)
    }
    
}
