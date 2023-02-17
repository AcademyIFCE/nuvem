import XCTest
import CloudKit
@testable import Nuvem

final class NuvemTests: XCTestCase {

    struct M: CKModel {
        
        var record: CKRecord!
        
        @CKField("a")
        var a: Int
        
        @CKField("b")
        var b: Double
        
        @CKField("c")
        var c: String
        
        @CKField("d")
        var d: Bool
        
        @CKField("e")
        var e: Date
        
        @CKField("e2")
        var e2: Date?
        
        @CKField("f", default: 0)
        var f: Int
        
        @CKReferenceField("r")
        var r: M2?
        
    }
    
    struct M2: CKModel {
        var record: CKRecord!
    }
    
    func testCKFieldValue_RawRepresentable() {
        
        enum E: String, CKFieldValue {
            case a
        }
        
        XCTAssertEqual(E.set(.a) as! String, "a")
        XCTAssertEqual(E.get("a" as CKRecordValue)!, .a)
        
        XCTAssertNil(E.get(1 as CKRecordValue))
        
    }
    
    func testCKFieldValue_Optional() {
        
        XCTAssertEqual(Bool?.set(true) as! Int, 1)
        XCTAssertEqual(Bool?.get(1 as CKRecordValue), true)
        
        XCTAssertEqual(Bool?.set(false) as! Int, 0)
        XCTAssertEqual(Bool?.get(0 as CKRecordValue), false)
                
    }
    
    func testCKFieldValue_Array() {
        
        XCTAssertEqual([Bool].set([true, false, true, false]) as! [Int], [1, 0, 1, 0])
        XCTAssertEqual([Bool].get([1, 0, 1, 0] as CKRecordValue), [true, false, true, false])
                
    }
    
    func testCKField_1() {
        
        @CKField("a") var f: Int
        
        let r = CKRecord(recordType: M.recordType)
        
        r["a"] = 1
    
        _f.storage.record = r
        
        XCTAssertEqual(f, 1)
        
    }
    
    func testCKField_2() {
        
        @CKField("a") var f: Int
        
        let r = CKRecord(recordType: M.recordType)
        
        f = 2
        
        _f.storage.record = r
        
        XCTAssertEqual(r["a"], 2)
        
    }
    
    func testCKField_3() {
        
        @CKField("a") var f: Int
        
        let r = CKRecord(recordType: M.recordType)
        
        _f.storage.record = r
        
        f = 3
        
        XCTAssertNil(r["a"])
        
        _f.storage.updateRecord()
        
        XCTAssertEqual(r["a"], 3)
        
    }
    
    func testCKModel() {
        
        let record = CKRecord(recordType: "M")
        
        var m = M(record: record)
        
        XCTAssertEqual(M.recordType, "M")
        
        XCTAssertEqual(m.id, record.recordID.recordName)
        XCTAssertEqual(m.creationDate, nil)
        XCTAssertEqual(m.modificationDate, nil)
        
        XCTAssertTrue(m.$a.storage.record?.recordID == record.recordID)
        XCTAssertTrue(m.$b.storage.record?.recordID == record.recordID)
        XCTAssertTrue(m.$c.storage.record?.recordID == record.recordID)
        
        m.a = 5
        m.b = 5
        
        let mCopy = m
        
        m.a = 6
        m.b = 6
        
        m = mCopy
        
        m.updateRecordWithFields()
        
        
        XCTAssertEqual(record["b"]!, 5)
        XCTAssertEqual(record["a"]!, 5)
                
    }
    
    func testStorage() {
        
        let r0 = CKRecord(recordType: "M")
        
        let s0 = FieldStorage(key: nil)
        
        s0.record = r0
                
        let r1 = CKRecord(recordType: "M")
        
        let s1 = FieldStorage(key: "a")
        
        r1["a"] = 1
        
        s1.record = r1
        
        XCTAssertEqual(s1.recordValue as! Int, 1)
        
        let r2 = CKRecord(recordType: "M")
        
        let s2 = FieldStorage(key: "a")
        
        s2.recordValue = 2 as any CKRecordValue
        
        s2.record = r2
        
        XCTAssertEqual(r2["a"], 2)
        
        let r3 = CKRecord(recordType: "M")
        
        let s3 = FieldStorage(key: "a")
                
        s3.record = r3
        
        s3.recordValue = 3 as any CKRecordValue
        
        s3.updateRecord()
        
        XCTAssertEqual(r3["a"], 3)
        
    }
    
    func testDesiredKeysBuilder() throws {
        
        let builder = DesiredKeysBuilder<M>()
        
        XCTAssertEqual(builder.desiredKeys, nil)
        
        builder.add(\.$a)
        
        XCTAssertEqual(builder.desiredKeys, ["a"])
        
        builder.add(\.$b, \.$c)
        
        XCTAssertEqual(builder.desiredKeys, ["a", "b", "c"])
        
    }
    
    func testFilters() throws {
        
        let f1: CKComparisonFilter<M> = \.$a == 1
        
        XCTAssertEqual(f1._operator, .isEqualTo)
        
        let f2: CKComparisonFilter<M> = \.$a != 1
        
        XCTAssertEqual(f2._operator, .isNotEqualTo)
        
        let f3: CKComparisonFilter<M> = \.$a > 1
        
        XCTAssertEqual(f3._operator, .isGreaterThan)
        
        let f4: CKComparisonFilter<M> = \.$a >= 1
        
        XCTAssertEqual(f4._operator, .isGreaterThanOrEqualTo)
        
        let f5: CKComparisonFilter<M> = \.$a < 1
        
        XCTAssertEqual(f5._operator, .isLessThan)
        
        let f6: CKComparisonFilter<M> = \.$a <= 1
        
        XCTAssertEqual(f6._operator, .isLessThanOrEqualTo)
        
        let f7: CKLogicFilter<M> = f1 && f2
        
        XCTAssertEqual(f7._operator, .and)
        
        let f8: CKLogicFilter<M> = f1 || f2
        
        XCTAssertEqual(f8._operator, .or)
        
        let r = M2(record: CKRecord(recordType: "M2"))
        
        let f9: CKComparisonFilter<M> = \.$r == r.id
        
        XCTAssertEqual(f9._operator, .isEqualTo)
        
        let f10: CKComparisonFilter<M> = \.$r == r
        
        XCTAssertEqual(f10._operator, .isEqualTo)
        
    }
    
    func testPredicates() {
        
        let f1: CKComparisonFilter<M> = \.$a == 1
        
        let p1 = f1.predicate
        
        XCTAssertEqual(p1, NSPredicate(format: "a == %@", NSNumber(value: 1)))
        
        let f2: CKComparisonFilter<M> = \.$b == 1.5
        
        let p2 = f2.predicate
        
        XCTAssertEqual(p2, NSPredicate(format: "b == %@", 1.5))
        
        let f3: CKComparisonFilter<M> = \.$c == "hello"
        
        let p3 = f3.predicate
        
        XCTAssertEqual(p3, NSPredicate(format: "c == %@", "hello"))
        
        let f4: CKComparisonFilter<M> = \.$d == true
        
        let p4 = f4.predicate
        
        XCTAssertEqual(p4, NSPredicate(format: "d == %@", NSNumber(booleanLiteral: true)))
        
        let f5: CKComparisonFilter<M> = \.$e == Date(timeIntervalSinceReferenceDate: 1000)
        
        let p5 = f5.predicate
        
        XCTAssertEqual(p5, NSPredicate(format: "e == %@", Date(timeIntervalSinceReferenceDate: 1000) as NSDate))
        
        let f6: CKLogicFilter<M> = (\.$a == 1) && (\.$b == 1.5)
        
        let p6 = f6.predicate
        
        XCTAssertEqual(p6, NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2]))
        
        let f7: CKLogicFilter<M> = (\.$a == 1) || (\.$b == 1.5)
        
        let p7 = f7.predicate
        
        XCTAssertEqual(p7, NSCompoundPredicate(orPredicateWithSubpredicates: [p1, p2]))
        
        let f8: CKLogicFilter<M> = (\.$a == 1) && (\.$b == 1.5) && (\.$c == "hello")
        
        let p8 = f8.predicate
        
        XCTAssertEqual(p8, NSCompoundPredicate(andPredicateWithSubpredicates: [p6, p3]))
        
        let f9: CKLogicFilter<M> = (\.$a == 1) || (\.$b == 1.5) || (\.$c == "hello")
        
        let p9 = f9.predicate
        
        XCTAssertEqual(p9, NSCompoundPredicate(orPredicateWithSubpredicates: [p7, p3]))
        
    }
    
    func testSort() {
        
        let s1 = CKSort<M>(\.$a, order: .ascending)
        
        let d1 = s1.descriptor
        
        XCTAssertEqual(d1.key, "a")
        XCTAssertTrue(d1.ascending)
        
        let s2 = CKSort<M>(\.$a, order: .descending)
        
        let d2 = s2.descriptor
        
        XCTAssertEqual(d2.key, "a")
        XCTAssertFalse(d2.ascending)
        
    }
    
}
