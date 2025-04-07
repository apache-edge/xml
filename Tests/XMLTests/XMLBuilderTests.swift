import Testing
@testable import XML

struct XMLBuilderTests {
    
    @Test func testBasicBuilding() async throws {
        // Build a simple XML document
        let builder = XML.build(root: "root")
        let document = builder.xmlDocument
        
        #expect(document.root.name == "root")
        #expect(document.xmlString == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root />")
    }
    
    @Test func testBuildWithAttributes() async throws {
        // Build a document with root attributes
        let builder = XML.build(root: "root", attributes: ["id": "123", "name": "test"])
        let document = builder.xmlDocument
        
        #expect(document.root.name == "root")
        #expect(document.root.attributes["id"] == "123")
        #expect(document.root.attributes["name"] == "test")
    }
    
    @Test func testBuildWithChildren() async throws {
        // Build a document with child elements
        let builder = XML.build(root: "root")
            .element(name: "child", attributes: ["id": "1"], content: "First")
            .parent()
            .element(name: "child", attributes: ["id": "2"], content: "Second")
            .parent()
        
        let document = builder.xmlDocument
        
        #expect(document.root.name == "root")
        #expect(document.root.childElements.count == 2)
        
        let firstChild = document.root.childElements[0]
        #expect(firstChild.name == "child")
        #expect(firstChild.attributes["id"] == "1")
        #expect(firstChild.textContent == "First")
        
        let secondChild = document.root.childElements[1]
        #expect(secondChild.name == "child")
        #expect(secondChild.attributes["id"] == "2")
        #expect(secondChild.textContent == "Second")
    }
    
    @Test func testBuildWithNestedChildren() async throws {
        // Build a document with nested elements
        let builder = XML.build(root: "root")
            .element(name: "parent")
                .element(name: "child", content: "Child Content")
                .parent()
            .parent()
        
        let document = builder.xmlDocument
        
        #expect(document.root.name == "root")
        #expect(document.root.childElements.count == 1)
        
        let parent = document.root.childElements[0]
        #expect(parent.name == "parent")
        #expect(parent.childElements.count == 1)
        
        let child = parent.childElements[0]
        #expect(child.name == "child")
        #expect(child.textContent == "Child Content")
    }
    
    @Test func testBuildWithClosures() async throws {
        // Build using closures
        let builder = XMLBuilder(rootName: "library")
        
        // Add first book
        builder.element(name: "book", attributes: ["category": "fiction"])
        builder.element(name: "title", content: "The Hitchhiker's Guide to the Galaxy")
        builder.parent()
        builder.element(name: "author", content: "Douglas Adams")
        builder.parent()
        builder.element(name: "year", content: "1979")
        builder.parent()
        builder.parent()
        
        // Add second book
        builder.element(name: "book", attributes: ["category": "non-fiction"])
        builder.element(name: "title", content: "A Brief History of Time")
        builder.parent()
        builder.element(name: "author", content: "Stephen Hawking")
        builder.parent()
        builder.element(name: "year", content: "1988")
        builder.parent()
        builder.parent()
        
        let document = builder.xmlDocument
        
        #expect(document.root.name == "library")
        #expect(document.root.childElements.count == 2)
        
        // Check first book
        let firstBook = document.root.childElements[0]
        #expect(firstBook.name == "book")
        #expect(firstBook.attributes["category"] == "fiction")
        #expect(firstBook.childElements.count == 3)
        
        let title = firstBook.childElements[0]
        #expect(title.name == "title")
        #expect(title.textContent == "The Hitchhiker's Guide to the Galaxy")
    }
    
    @Test func testBuildWithComments() async throws {
        // Build with comments
        let builder = XML.build(root: "root")
            .documentComment("Root comment")
            .element(name: "element")
                .comment("Element comment")
                .text("Content")
            .parent()
        
        let document = builder.xmlDocument
        
        #expect(document.comments.count == 1)
        #expect(document.comments[0].text == "Root comment")
        
        let element = document.root.childElements[0]
        #expect(element.children.count == 2)
        #expect(element.children[0] is XMLComment)
        
        let comment = element.children[0] as! XMLComment
        #expect(comment.text == "Element comment")
    }
    
    @Test func testBuildWithCData() async throws {
        // Build with CDATA
        let builder = XML.build(root: "root")
            .element(name: "element")
                .cdata("<greeting>Hello</greeting>")
            .parent()
        
        let document = builder.xmlDocument
        
        let element = document.root.childElements[0]
        #expect(element.children.count == 1)
        #expect(element.children[0] is XMLCData)
        
        let cdata = element.children[0] as! XMLCData
        #expect(cdata.text == "<greeting>Hello</greeting>")
    }
    
    @Test func testBuildWithProcessingInstructions() async throws {
        // Build with processing instructions
        let builder = XML.build(root: "root")
            .processingInstruction(target: "xml-stylesheet", data: "type=\"text/xsl\" href=\"style.xsl\"")
            .element(name: "element")
                .instruction(target: "php", data: "echo \"Hello World\"; ")
            .parent()
        
        let document = builder.xmlDocument
        
        #expect(document.processingInstructions.count == 1)
        #expect(document.processingInstructions[0].target == "xml-stylesheet")
        #expect(document.processingInstructions[0].data == "type=\"text/xsl\" href=\"style.xsl\"")
        
        let element = document.root.childElements[0]
        #expect(element.children.count == 1)
        #expect(element.children[0] is XMLProcessingInstruction)
        
        let pi = element.children[0] as! XMLProcessingInstruction
        #expect(pi.target == "php")
        #expect(pi.data == "echo \"Hello World\"; ")
    }
    
    @Test func testBuildLibraryCatalog() async throws {
        // Test building a more complex document
        let builder = XML.build(root: "library", attributes: ["name": "Public Library"])
            .documentComment("Library catalog")
        
        // Add first book
        builder.element(name: "book", attributes: ["category": "fiction", "bestseller": "true"])
        builder.element(name: "title", content: "The Hitchhiker's Guide to the Galaxy")
        builder.parent()
        builder.element(name: "author", content: "Douglas Adams")
        builder.parent()
        builder.element(name: "year", content: "1979")
        builder.parent()
        builder.element(name: "publisher", content: "Pan Books")
        builder.parent()
        builder.comment("Science fiction comedy")
        builder.parent()
        
        // Add second book
        builder.element(name: "book", attributes: ["category": "non-fiction", "bestseller": "true"])
        builder.element(name: "title", content: "A Brief History of Time")
        builder.parent()
        builder.element(name: "author", content: "Stephen Hawking")
        builder.parent()
        builder.element(name: "year", content: "1988")
        builder.parent()
        builder.element(name: "publisher", content: "Bantam Books")
        builder.parent()
        builder.cdata("<description>A landmark volume in science</description>")
        builder.parent()
        
        // Add magazine
        builder.element(name: "magazine", attributes: ["frequency": "monthly"])
        builder.element(name: "title", content: "National Geographic")
        builder.parent()
        builder.element(name: "publisher", content: "National Geographic Society")
        builder.parent()
        builder.element(name: "year", content: "2022")
        builder.parent()
        builder.parent()
        
        let document = builder.xmlDocument
        
        #expect(document.root.name == "library")
        #expect(document.root.attributes["name"] == "Public Library")
        #expect(document.root.childElements.count == 3)
        #expect(document.comments.count == 1)
        
        // Verify first book
        let firstBook = document.root.childElements[0]
        #expect(firstBook.name == "book")
        #expect(firstBook.attributes["category"] == "fiction")
        #expect(firstBook.attributes["bestseller"] == "true")
        #expect(firstBook.childElements.count == 4)
        #expect(firstBook.children.count == 5) // 4 elements + 1 comment
        
        // Check that one of the children is a comment
        let hasComment = firstBook.children.contains { $0 is XMLComment }
        #expect(hasComment)
        
        // Verify second book
        let secondBook = document.root.childElements[1]
        #expect(secondBook.name == "book")
        #expect(secondBook.attributes["category"] == "non-fiction")
        
        // Check that one of the children is a CDATA
        let hasCData = secondBook.children.contains { $0 is XMLCData }
        #expect(hasCData)
        
        // Verify magazine
        let magazine = document.root.childElements[2]
        #expect(magazine.name == "magazine")
        #expect(magazine.attributes["frequency"] == "monthly")
        #expect(magazine.childElements.count == 3)
    }
}