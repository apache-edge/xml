import Testing
@testable import XML

struct XMLParserTests {
    
    func testParseElement() async throws {
        // Test parsing a simple element
        let xmlString = "<root></root>"
        let document = try XML.parse(string: xmlString)
        
        #expect(document.root.name == "root")
        #expect(document.root.children.isEmpty)
    }
    
    func testParseElementWithAttributes() async throws {
        // Test parsing an element with attributes
        let xmlString = "<root id=\"123\" name=\"test\"></root>"
        let document = try XML.parse(string: xmlString)
        
        #expect(document.root.name == "root")
        #expect(document.root.attributes["id"] == "123")
        #expect(document.root.attributes["name"] == "test")
    }
    
    func testParseSelfClosingElement() async throws {
        // Test parsing a self-closing element
        let xmlString = "<root id=\"123\" />"
        let document = try XML.parse(string: xmlString)
        
        #expect(document.root.name == "root")
        #expect(document.root.attributes["id"] == "123")
        #expect(document.root.children.isEmpty)
    }
    
    func testParseElementWithContent() async throws {
        // Test parsing an element with text content
        let xmlString = "<root>Hello World</root>"
        let document = try XML.parse(string: xmlString)
        
        #expect(document.root.name == "root")
        #expect(document.root.children.count == 1)
        #expect(document.root.children[0] is XMLText)
        
        let textNode = document.root.children[0] as! XMLText
        #expect(textNode.text == "Hello World")
    }
    
    func testParseElementWithChildren() async throws {
        // Test parsing an element with child elements
        let xmlString = """
        <root>
            <child id="1">First</child>
            <child id="2">Second</child>
        </root>
        """
        let document = try XML.parse(string: xmlString)
        
        #expect(document.root.name == "root")
        #expect(document.root.childElements.count == 2)
        
        let firstChild = document.root.childElements[0]
        #expect(firstChild.name == "child")
        #expect(firstChild.attributes["id"] == "1")
        #expect(firstChild.textNodes.count == 1)
        #expect(firstChild.textNodes[0].text == "First")
        
        let secondChild = document.root.childElements[1]
        #expect(secondChild.name == "child")
        #expect(secondChild.attributes["id"] == "2")
        #expect(secondChild.textNodes.count == 1)
        #expect(secondChild.textNodes[0].text == "Second")
    }
    
    func testParseElementWithNestedChildren() async throws {
        // Test parsing an element with nested child elements
        let xmlString = """
        <root>
            <parent>
                <child>Child Content</child>
            </parent>
        </root>
        """
        let document = try XML.parse(string: xmlString)
        
        #expect(document.root.name == "root")
        #expect(document.root.childElements.count == 1)
        
        let parent = document.root.childElements[0]
        #expect(parent.name == "parent")
        #expect(parent.childElements.count == 1)
        
        let child = parent.childElements[0]
        #expect(child.name == "child")
        #expect(child.textNodes.count == 1)
        #expect(child.textNodes[0].text == "Child Content")
    }
    
    func testParseComment() async throws {
        // Test parsing a comment
        let xmlString = """
        <root>
            <!-- This is a comment -->
            <element>Content</element>
        </root>
        """
        let document = try XML.parse(string: xmlString)
        
        #expect(document.root.name == "root")
        #expect(document.root.children.count == 2)
        #expect(document.root.children[0] is XMLComment)
        
        let comment = document.root.children[0] as! XMLComment
        #expect(comment.text == " This is a comment ")
    }
    
    func testParseCData() async throws {
        // Test parsing a CDATA section
        let xmlString = """
        <root>
            <element><![CDATA[<greeting>Hello</greeting>]]></element>
        </root>
        """
        let document = try XML.parse(string: xmlString)
        
        #expect(document.root.name == "root")
        #expect(document.root.childElements.count == 1)
        
        let element = document.root.childElements[0]
        #expect(element.name == "element")
        #expect(element.children.count == 1)
        #expect(element.children[0] is XMLCData)
        
        let cdata = element.children[0] as! XMLCData
        #expect(cdata.text == "<greeting>Hello</greeting>")
    }
    
    func testParseProcessingInstruction() async throws {
        // Test parsing a processing instruction
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <?xml-stylesheet type="text/xsl" href="style.xsl"?>
        <root></root>
        """
        let document = try XML.parse(string: xmlString)
        
        #expect(document.version == "1.0")
        #expect(document.encoding == "UTF-8")
        #expect(document.processingInstructions.count == 1)
        
        let pi = document.processingInstructions[0]
        #expect(pi.target == "xml-stylesheet")
        #expect(pi.data == "type=\"text/xsl\" href=\"style.xsl\"")
    }
    
    func testParseWithEntities() async throws {
        // Test parsing XML with entities
        let xmlString = """
        <root>
            <element attribute="&quot;quoted&quot;">
                &lt;text&gt; with &amp; special &apos;characters&apos;
            </element>
        </root>
        """
        let document = try XML.parse(string: xmlString)
        
        #expect(document.root.name == "root")
        #expect(document.root.childElements.count == 1)
        
        let element = document.root.childElements[0]
        #expect(element.name == "element")
        #expect(element.attributes["attribute"] == "\"quoted\"")
        
        // The text will have normalized whitespace
        let textContent = element.textContent.trimmingCharacters(in: .whitespacesAndNewlines)
        #expect(textContent == "<text> with & special 'characters'")
    }
    
    func testParseMalformedXML() async throws {
        // Test parsing malformed XML
        let xmlString = "<root><unclosed></root>"
        
        do {
            _ = try XML.parse(string: xmlString)
            #expect(false, "Expected parsing to fail with malformed XML")
        } catch {
            #expect(error is XMLParseError)
        }
    }
    
    func testParseComplexXML() async throws {
        // Test parsing a more complex XML structure
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!-- Library catalog -->
        <library>
            <book category="fiction">
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
            </book>
            <magazine frequency="monthly">
                <title>National Geographic</title>
                <publisher>National Geographic Society</publisher>
                <year>2022</year>
            </magazine>
        </library>
        """
        
        let document = try XML.parse(string: xmlString)
        
        #expect(document.root.name == "library")
        #expect(document.root.childElements.count == 3)
        
        // Check the first book
        let firstBook = document.root.childElements[0]
        #expect(firstBook.name == "book")
        #expect(firstBook.attributes["category"] == "fiction")
        #expect(firstBook.childElements.count == 4)
        
        let title = firstBook.childElements[0]
        #expect(title.name == "title")
        #expect(title.textContent == "The Hitchhiker's Guide to the Galaxy")
        
        let author = firstBook.childElements[1]
        #expect(author.name == "author")
        #expect(author.textContent == "Douglas Adams")
        
        let year = firstBook.childElements[2]
        #expect(year.name == "year")
        #expect(year.textContent == "1979")
        
        // Check the magazine
        let magazine = document.root.childElements[2]
        #expect(magazine.name == "magazine")
        #expect(magazine.attributes["frequency"] == "monthly")
        #expect(magazine.childElements.count == 3)
        
        let magazineTitle = magazine.childElements[0]
        #expect(magazineTitle.name == "title")
        #expect(magazineTitle.textContent == "National Geographic")
    }
}