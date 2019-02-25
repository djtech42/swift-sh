@testable import Script
import Version
import XCTest
import Path

class UnitTests: XCTestCase {
    func testWigglyArrow() {
        let a = parse("import Foo // @mxcl ~> 1.0")
        XCTAssertEqual(a?.dependencyName, "mxcl/Foo")
        XCTAssertEqual(a?.constraint, .upToNextMajor(from: .one))
        XCTAssertEqual(a?.importName, "Foo")
    }

    func testTrailingWhitespace() {
        let a = parse("import Foo // @mxcl ~> 1.0 ")
        XCTAssertEqual(a?.dependencyName, "mxcl/Foo")
        XCTAssertEqual(a?.constraint, .upToNextMajor(from: .one))
        XCTAssertEqual(a?.importName, "Foo")
    }

    func testExact() {
        let a = parse("import Foo // @mxcl == 1.0")
        XCTAssertEqual(a?.dependencyName, "mxcl/Foo")
        XCTAssertEqual(a?.constraint, .exact(.one))
        XCTAssertEqual(a?.importName, "Foo")
    }

    func testMoreSpaces() {
        let b = parse("import    Foo       //     @mxcl    ~>      1.0")
        XCTAssertEqual(b?.dependencyName, "mxcl/Foo")
        XCTAssertEqual(b?.constraint, .upToNextMajor(from: .one))
        XCTAssertEqual(b?.importName, "Foo")
    }

    func testMinimalSpaces() {
        let b = parse("import Foo//@mxcl~>1.0")
        XCTAssertEqual(b?.dependencyName, "mxcl/Foo")
        XCTAssertEqual(b?.constraint, .upToNextMajor(from: .one))
        XCTAssertEqual(b?.importName, "Foo")
    }

    func testCanOverrideImportName() {
        let b = parse("import Foo  // mxcl/Bar ~> 1.0")
        XCTAssertEqual(b?.dependencyName, "mxcl/Bar")
        XCTAssertEqual(b?.constraint, .upToNextMajor(from: .one))
        XCTAssertEqual(b?.importName, "Foo")
    }
    
    func testCanOverrideImportNameUsingNameWithHyphen() {
        let b = parse("import Bar  // mxcl/swift-bar ~> 1.0")
        XCTAssertEqual(b?.dependencyName, "mxcl/swift-bar")
        XCTAssertEqual(b?.constraint, .upToNextMajor(from: .one))
        XCTAssertEqual(b?.importName, "Bar")
    }

    func testCanProvideFullURL() {
        let b = parse("import Foo  // https://example.com/mxcl/Bar.git ~> 1.0")
        XCTAssertEqual(b?.dependencyName, "https://example.com/mxcl/Bar.git")
        XCTAssertEqual(b?.constraint, .upToNextMajor(from: .one))
        XCTAssertEqual(b?.importName, "Foo")
    }

    func testCanProvideFullURLWithHyphen() {
        let b = parse("import Bar  // https://example.com/mxcl/swift-bar.git ~> 1.0")
        XCTAssertEqual(b?.dependencyName, "https://example.com/mxcl/swift-bar.git")
        XCTAssertEqual(b?.constraint, .upToNextMajor(from: .one))
        XCTAssertEqual(b?.importName, "Bar")
    }

    func testCanDoSpecifiedImports() {
        let kinds = [
            "struct",
             "class",
             "enum",
             "protocol",
             "typealias",
             "func",
             "let",
             "var"
        ]
        for kind in kinds {
            let b = parse("import \(kind) Foo.bar  // https://example.com/mxcl/Bar.git ~> 1.0")
            XCTAssertEqual(b?.dependencyName, "https://example.com/mxcl/Bar.git")
            XCTAssertEqual(b?.constraint, .upToNextMajor(from: .one))
            XCTAssertEqual(b?.importName, "Foo")
        }
    }

    func testCanUseTestable() {
        let b = parse("@testable import Foo  // @bar ~> 1.0")
        XCTAssertEqual(b?.dependencyName, "bar/Foo")
        XCTAssertEqual(b?.constraint, .upToNextMajor(from: .one))
        XCTAssertEqual(b?.importName, "Foo")
    }

    func testLatestVersion() {
        let b = parse("import Foo  // @bar")
        XCTAssertEqual(b?.dependencyName, "bar/Foo")
        XCTAssertEqual(b?.constraint, .latest)
        XCTAssertEqual(b?.importName, "Foo")
    }

    func testSwiftVersion() {
    #if swift(>=5) || compiler(>=5.0)
        let expected = "5.0"
    #else
        let expected = "4.2"
    #endif
        XCTAssertEqual(swiftVersion, expected)
    }
}

extension Constraint: Equatable {
    public static func ==(lhs: Constraint, rhs: Constraint) -> Bool {
        switch (lhs, rhs) {
        case (.upToNextMajor(let v1), .upToNextMajor(let v2)), (.exact(let v1), .exact(let v2)):
            return v1 == v2
        case let (.ref(ref1), .ref(ref2)):
            return ref1 == ref2
        case (.latest, .latest):
            return true
        case (.latest, _):
            return false
        case (.ref, _):
            return false
        case (.exact, _):
            return false
        case (.upToNextMajor, _):
            return false
        }
    }
}

extension Version {
    static var one: Version {
        return Version(1,0,0)
    }
}
