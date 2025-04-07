import Testing
@testable import XML

// This runs the tests using Swift Testing
@main
struct XMLTests {
    static func main() async throws {
        let suiteResult = await SuiteResult(displayName: "XML Library") {
            // Parser Tests
            await TestCase("XML Parser Tests") { @TestBuilder in
                // Parse Elements
                try XMLParserTests().testParseElement()
                try XMLParserTests().testParseElementWithAttributes()
                try XMLParserTests().testParseSelfClosingElement()
                try XMLParserTests().testParseElementWithContent()
                try XMLParserTests().testParseElementWithChildren()
                try XMLParserTests().testParseElementWithNestedChildren()
                
                // Parse Node Types
                try XMLParserTests().testParseComment()
                try XMLParserTests().testParseCData()
                try XMLParserTests().testParseProcessingInstruction()
                
                // Edge Cases
                try XMLParserTests().testParseWithEntities()
                try XMLParserTests().testParseMalformedXML()
                try XMLParserTests().testParseComplexXML()
            }
            
            // Query Tests
            await TestCase("XML Query Tests") { @TestBuilder in
                try XMLQueryTests().testBasicQuery()
                try XMLQueryTests().testAttributeQuery()
                try XMLQueryTests().testWildcardQuery()
                try XMLQueryTests().testQueryChaining()
                try XMLQueryTests().testNestedQuery()
                try XMLQueryTests().testQueryFirst()
                try XMLQueryTests().testTextContentQuery()
                try XMLQueryTests().testParentQuery()
                try XMLQueryTests().testMultiLevelQuery()
            }
            
            // Builder Tests
            await TestCase("XML Builder Tests") { @TestBuilder in
                try XMLBuilderTests().testBasicBuilding()
                try XMLBuilderTests().testBuildWithAttributes()
                try XMLBuilderTests().testBuildWithChildren()
                try XMLBuilderTests().testBuildWithNestedChildren()
                try XMLBuilderTests().testBuildWithClosures()
                try XMLBuilderTests().testBuildWithComments()
                try XMLBuilderTests().testBuildWithCData()
                try XMLBuilderTests().testBuildWithProcessingInstructions()
                try XMLBuilderTests().testBuildLibraryCatalog()
            }
            
            // Navigation Tests
            await TestCase("XML Navigation Tests") { @TestBuilder in
                try XMLNavigationTests().testChildElements()
                try XMLNavigationTests().testFirstChild()
                try XMLNavigationTests().testChildrenWhere()
                try XMLNavigationTests().testDescendants()
                try XMLNavigationTests().testNodes()
                try XMLNavigationTests().testParentChild()
                try XMLNavigationTests().testDepth()
                try XMLNavigationTests().testAddChild()
                try XMLNavigationTests().testRemoveChild()
                try XMLNavigationTests().testRemoveChildAtIndex()
                try XMLNavigationTests().testRemoveAllChildren()
                try XMLNavigationTests().testSetContent()
                try XMLNavigationTests().testSetAttribute()
                try XMLNavigationTests().testRemoveAttribute()
                try XMLNavigationTests().testSetAttributes()
                try XMLNavigationTests().testRename()
                try XMLNavigationTests().testCopy()
                try XMLNavigationTests().testDocumentCopy()
            }
            
            // Serialization Tests
            await TestCase("XML Serialization Tests") { @TestBuilder in
                try XMLSerializationTests().testSerializeElement()
                try XMLSerializationTests().testSerializeText()
                try XMLSerializationTests().testSerializeComment()
                try XMLSerializationTests().testSerializeCData()
                try XMLSerializationTests().testSerializeProcessingInstruction()
                try XMLSerializationTests().testSerializeDocument()
                try XMLSerializationTests().testSerializeComplex()
                try XMLSerializationTests().testRoundTrip()
                try XMLSerializationTests().testSpecialCharacters()
                try XMLSerializationTests().testFileIOWithTempFile()
            }
        }
        
        // Report results
        let reporter = DefaultTestReporter()
        reporter.report(suiteResult)
    }
}

// Helper classes for testing
struct TestCase: Sendable {
    let displayName: String
    let run: () async -> [TestResult]
    
    init(_ displayName: String, run: @escaping () async -> [TestResult]) {
        self.displayName = displayName
        self.run = run
    }
    
    init(_ displayName: String, @TestBuilder builder: () -> [TestResult]) async {
        self.displayName = displayName
        self.run = { builder() }
    }
}

struct SuiteResult: Sendable {
    let displayName: String
    let testCases: [TestCase]
    
    init(displayName: String, @SuiteBuilder builder: () async -> [TestCase]) async {
        self.displayName = displayName
        self.testCases = await builder()
    }
}

@resultBuilder
struct TestBuilder {
    static func buildBlock(_ components: TestResult...) -> [TestResult] {
        return components
    }
    
    static func buildExpression(_ expression: () throws -> Void) -> TestResult {
        do {
            try expression()
            return TestResult(name: "", passed: true, message: nil)
        } catch {
            return TestResult(name: "", passed: false, message: error.localizedDescription)
        }
    }
}

@resultBuilder
struct SuiteBuilder {
    static func buildBlock(_ components: TestCase...) -> [TestCase] {
        return components
    }
}

struct TestResult: Sendable {
    let name: String
    let passed: Bool
    let message: String?
}

// Simple test reporter
struct DefaultTestReporter {
    func report(_ suiteResult: SuiteResult) {
        print("Running test suite: \(suiteResult.displayName)")
        
        Task {
            var totalTests = 0
            var passedTests = 0
            
            for testCase in suiteResult.testCases {
                print("\nRunning test case: \(testCase.displayName)")
                let results = await testCase.run()
                
                totalTests += results.count
                passedTests += results.filter(\.passed).count
                
                for (index, result) in results.enumerated() {
                    let status = result.passed ? "✅ PASSED" : "❌ FAILED"
                    print("  Test #\(index + 1): \(status)")
                    
                    if let message = result.message, !result.passed {
                        print("    Error: \(message)")
                    }
                }
            }
            
            print("\nTest Summary: \(passedTests)/\(totalTests) tests passed")
        }
    }
}