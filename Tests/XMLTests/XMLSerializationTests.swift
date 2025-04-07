import Testing
@testable import XML
import Foundation

struct XMLSerializationTests {
    
    func testSerializeElement() async throws {
        // Create an element and check its XML string
        let element = XML.element(name: "element")
        #expect(element.xmlString == "<element />")
        
        // Element with attributes
        let elementWithAttrs = XML.element(name: "element", attributes: ["id": "123", "name": "test"])
        #expect(elementWithAttrs.xmlString == "<element id=\"123\" name=\"test\" />")
        
        // Element with content
        let elementWithContent = XML.element(name: "element", content: "Content")
        #expect(elementWithContent.xmlString == "<element>Content</element>")
        
        // Element with children
        let parent = XML.element(name: "parent")
        parent.addChild(XML.element(name: "child", content: "Child Content"))
        #expect(parent.xmlString == "<parent><child>Child Content</child></parent>")
    }
    
    func testSerializeText() async throws {
        // Simple text
        let text = XML.text("Simple text")
        #expect(text.xmlString == "Simple text")
        
        // Text with special characters
        let specialText = XML.text("<text> with & special characters")
        #expect(specialText.xmlString == "&lt;text&gt; with &amp; special characters")
    }
    
    func testSerializeComment() async throws {
        let comment = XML.comment("This is a comment")
        #expect(comment.xmlString == "<!-- This is a comment -->")
    }
    
    func testSerializeCData() async throws {
        let cdata = XML.cdata("<greeting>Hello</greeting>")
        #expect(cdata.xmlString == "<![CDATA[<greeting>Hello</greeting>]]>")
    }
    
    func testSerializeProcessingInstruction() async throws {
        let pi = XML.processingInstruction(target: "xml-stylesheet", data: "type=\"text/xsl\" href=\"style.xsl\"")
        #expect(pi.xmlString == "<?xml-stylesheet type=\"text/xsl\" href=\"style.xsl\"?>")
    }
    
    func testSerializeDocument() async throws {
        // Create a document
        let root = XML.element(name: "root")
        let document = XMLDocument(root: root)
        
        // Check XML string
        #expect(document.xmlString == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root />")
        
        // Document with custom version and encoding
        let customDocument = XMLDocument(root: root, version: "1.1", encoding: "ISO-8859-1")
        #expect(customDocument.xmlString.contains("version=\"1.1\""))
        #expect(customDocument.xmlString.contains("encoding=\"ISO-8859-1\""))
        
        // Document with processing instructions and comments
        let complexDoc = XMLDocument(root: root, version: "1.0", encoding: "UTF-8")
        complexDoc.addProcessingInstruction(XMLProcessingInstruction(
            target: "xml-stylesheet", 
            data: "type=\"text/xsl\" href=\"style.xsl\""
        ))
        complexDoc.addComment(XMLComment(text: "This is a comment"))
        
        let xmlString = complexDoc.xmlString
        #expect(xmlString.contains("<?xml-stylesheet"))
        #expect(xmlString.contains("<!-- This is a comment -->"))
    }
    
    func testSerializeComplex() async throws {
        // Create a complex document
        let builder = XML.build(root: "library")
            .documentComment("Library catalog")
            .element(name: "book", attributes: ["category": "fiction"])
                .element(name: "title", content: "The Hitchhiker's Guide to the Galaxy")
                .parent()
                .element(name: "author", content: "Douglas Adams")
                .parent()
                .element(name: "year", content: "1979")
                .parent()
                .comment("Science fiction comedy")
            .parent()
            .element(name: "book", attributes: ["category": "non-fiction"])
                .element(name: "title", content: "A Brief History of Time")
                .parent()
                .element(name: "author", content: "Stephen Hawking")
                .parent()
                .element(name: "year", content: "1988")
                .parent()
                .cdata("<description>A landmark volume in science</description>")
            .parent()
        
        let document = builder.xmlDocument
        let xmlString = document.xmlString
        
        // Verify the serialized document contains all the elements
        #expect(xmlString.contains("<library>"))
        #expect(xmlString.contains("<book category=\"fiction\">"))
        #expect(xmlString.contains("<title>The Hitchhiker's Guide to the Galaxy</title>"))
        #expect(xmlString.contains("<!-- Science fiction comedy -->"))
        #expect(xmlString.contains("<![CDATA[<description>A landmark volume in science</description>]]>"))
    }
    
    func testRoundTrip() async throws {
        // Create a document
        let originalXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!-- Library catalog -->
        <library>
            <book category="fiction" bestseller="true">
                <title>The Hitchhiker's Guide to the Galaxy</title>
                <author>Douglas Adams</author>
                <year>1979</year>
                <publisher>Pan Books</publisher>
            </book>
            <book category="non-fiction">
                <title>A Brief History of Time</title>
                <author>Stephen Hawking</author>
                <year>1988</year>
                <publisher>Bantam Books</publisher>
                <![CDATA[<description>A landmark volume in science</description>]]>
            </book>
        </library>
        """
        
        // Parse the document
        let document = try XML.parse(string: originalXML)
        
        // Serialize back to string
        let serialized = document.xmlString
        
        // Parse again
        let reparsed = try XML.parse(string: serialized)
        
        // Verify the documents are equivalent
        #expect(reparsed.root.name == document.root.name)
        #expect(reparsed.root.childElements.count == document.root.childElements.count)
        
        // Compare the first book
        let originalBook = document.root.childElements[0]
        let reparsedBook = reparsed.root.childElements[0]
        
        #expect(reparsedBook.name == originalBook.name)
        #expect(reparsedBook.attributes["category"] == originalBook.attributes["category"])
        #expect(reparsedBook.attributes["bestseller"] == originalBook.attributes["bestseller"])
        #expect(reparsedBook.childElements.count == originalBook.childElements.count)
        
        // Compare the title
        let originalTitle = originalBook.childElements[0]
        let reparsedTitle = reparsedBook.childElements[0]
        
        #expect(reparsedTitle.name == originalTitle.name)
        #expect(reparsedTitle.textContent == originalTitle.textContent)
    }
    
    func testSpecialCharacters() async throws {
        // Test escaping special characters
        let element = XML.element(name: "element", attributes: ["attr": "value with \"quotes\""])
        element.addChild(XML.text("Text with <tags> & ampersands"))
        
        let xmlString = element.xmlString
        
        #expect(xmlString.contains("attr=\"value with &quot;quotes&quot;\""))
        #expect(xmlString.contains("Text with &lt;tags&gt; &amp; ampersands"))
        
        // Parse it back
        let document = try XML.parse(string: "<root>\(xmlString)</root>")
        let parsedElement = document.root.childElements[0]
        
        #expect(parsedElement.attributes["attr"] == "value with \"quotes\"")
        #expect(parsedElement.textContent == "Text with <tags> & ampersands")
    }
    
    func testFileIOWithTempFile() async throws {
        // Create a document
        let builder = XML.build(root: "root")
            .element(name: "child", content: "Content")
            .parent()
        
        let document = builder.xmlDocument
        
        // Create a temporary file path
        let tempFilePath = "/tmp/xml_test_\(UUID().uuidString).xml"
        let tempFileURL = URL(fileURLWithPath: tempFilePath)
        
        // Write to file
        try document.write(toFile: tempFilePath)
        
        // Read back from file
        let readDocument = try XML.parse(contentsOfFile: tempFilePath)
        
        // Verify the document was read correctly
        #expect(readDocument.root.name == "root")
        #expect(readDocument.root.childElements.count == 1)
        #expect(readDocument.root.childElements[0].name == "child")
        #expect(readDocument.root.childElements[0].textContent == "Content")
        
        // Clean up
        try FileManager.default.removeItem(at: tempFileURL)
    }
}