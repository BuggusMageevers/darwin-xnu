struct TestStruct {
    var var1: Int = 0
    let var2: Bool = false
    var var3: [Int] = [1, 2, 3, 4, 5, 6]
}

MemoryLayout<TestStruct>.size
MemoryLayout<TestStruct>.alignment
MemoryLayout<TestStruct>.stride

var testInstance: TestStruct = TestStruct()
//let testPointer1: UnsafePointer<TestStruct> = &testInstance /*  Use of extraneous '&' */
var testPointer2: UnsafeMutablePointer<TestStruct> = withUnsafeMutablePointer(to: &testInstance) { pointer in
    print("struct pointer:", pointer)
    return pointer
}
var testPointer2var3: UnsafeMutablePointer<Array<Int>> = withUnsafeMutablePointer(to: &testInstance.var3) { pointer in
    print("struct var1 pointer:", pointer)
    return pointer
}

print("struct before pointer manipulates values:", testInstance)
testPointer2.pointee.var1 = 1
print("struct after first first manipulation:", testInstance)
testPointer2var3.pointee[2] = 10

print("struct pointer:", testPointer2)
print("var1 pointer:", testPointer2var3)
print("struct pointer pointee:", testPointer2.pointee)
print("var1 pointer pointee:", testPointer2var3.pointee)
print("struct:", testInstance)

struct ipc_space {
    typealias ipc_entry_t = UnsafeMutablePointer<ipc_entry>
    struct ipc_entry {
        enum ie_index {
            case next(Int)
            case request(Double)
        }
        var index: ie_index
        var thing: Int = 0
    }
    var is_table: ipc_entry_t = withUnsafeMutablePointer(to: &thing) { return $0 }
}
var thing = ipc_space.ipc_entry(index: .next(1), thing: 0)

var space = ipc_space()
var table = withUnsafeMutablePointer(to: &space.is_table[0]) { pointer in return pointer }
var next_free = table[0].index


