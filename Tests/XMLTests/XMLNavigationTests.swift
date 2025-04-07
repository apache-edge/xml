import Testing
@testable import XML

struct XMLNavigationTests {
    
    let xmlString = """
    <library>
        <book category="fiction" bestseller="true">
            <title>The Hitchhiker's Guide to the Galaxy</title>
            <author>Douglas Adams</author>
            <year>1979</year>
            <publisher>Pan Books</publisher>
        </book>
        <book category="fiction">
            <title>The Lord of the Rings</title>
            <author>J.R.R. Tolkien</author>
            <year>1954</year>
            <publisher>Allen &amp; Unwin</publisher>
        </book>
        <book category="non-fiction" bestseller="true">
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
    
    @Test func testChildElements() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Get child elements
        let children = document.root.childElements
        #expect(children.count == 4)
        #expect(children[0].name == "book")
        #expect(children[1].name == "book")
        #expect(children[2].name == "book")
        #expect(children[3].name == "magazine")
    }
    
    @Test func testFirstChild() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Get first book
        let firstBook = document.root.firstChild(where: { $0.name == "book" })
        #expect(firstBook != nil)
        #expect(firstBook?.attributes["category"] == "fiction")
        
        // Get first non-fiction book
        let nonFictionBook = document.root.firstChild(where: { 
            $0.name == "book" && $0.attributes["category"] == "non-fiction" 
        })
        #expect(nonFictionBook != nil)
        #expect(nonFictionBook?.query("title")[0].textContent == "A Brief History of Time")
        
        // Get non-existent element
        let nonExistent = document.root.firstChild(where: { $0.name == "nonexistent" })
        #expect(nonExistent == nil)
    }
    
    @Test func testChildrenWhere() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Get all books
        let books = document.root.children(where: { $0.name == "book" })
        #expect(books.count == 3)
        
        // Get fiction books
        let fictionBooks = document.root.children(where: { 
            $0.name == "book" && $0.attributes["category"] == "fiction" 
        })
        #expect(fictionBooks.count == 2)
        
        // Get bestsellers
        let bestsellers = document.root.children(where: { 
            $0.attributes["bestseller"] == "true" 
        })
        #expect(bestsellers.count == 2)
    }
    
    @Test func testDescendants() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Get all titles
        let titles = document.root.descendants(where: { $0.name == "title" })
        #expect(titles.count == 4)
        
        // Get all years before 1980
        let yearsBefore1980 = document.root.descendants(where: { 
            $0.name == "year" && Int($0.textContent) ?? 0 < 1980 
        })
        #expect(yearsBefore1980.count == 2)
        
        // Get all elements with specific author
        let hawkingElements = document.root.descendants(where: { 
            $0.name == "author" && $0.textContent.contains("Hawking") 
        })
        #expect(hawkingElements.count == 1)
    }
    
    @Test func testNodes() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Get library and all books
        let libraryAndBooks = document.root.nodes(where: { 
            $0.name == "library" || $0.name == "book" 
        })
        #expect(libraryAndBooks.count == 4) // 1 library + 3 books
        
        // Check the first is the library itself
        #expect(libraryAndBooks[0].name == "library")
    }
    
    @Test func testParentChild() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Find a specific title
        let title = document.root.descendants(where: { 
            $0.name == "title" && $0.textContent == "The Hitchhiker's Guide to the Galaxy" 
        }).first
        
        #expect(title != nil)
        
        // Get its parent
        let book = title?.parent
        #expect(book != nil)
        #expect(book?.name == "book")
        
        // Verify relationship
        #expect(book?.childElements.contains { $0 === title } == true)
    }
    
    @Test func testDepth() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Root has depth 0
        #expect(document.root.depth == 0)
        
        // Books have depth 1
        let book = document.root.childElements[0]
        #expect(book.depth == 1)
        
        // Title has depth 2
        let title = book.childElements[0]
        #expect(title.depth == 2)
    }
    
    @Test func testAddChild() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Add a new book
        let newBook = XMLElement(name: "book", attributes: ["category": "science"])
        newBook.addChild(XMLElement(name: "title", content: "Cosmos"))
        newBook.addChild(XMLElement(name: "author", content: "Carl Sagan"))
        newBook.addChild(XMLElement(name: "year", content: "1980"))
        
        document.root.addChild(newBook)
        
        // Verify the child was added
        #expect(document.root.childElements.count == 5)
        
        let addedBook = document.root.childElements[4]
        #expect(addedBook.name == "book")
        #expect(addedBook.attributes["category"] == "science")
        
        // Check parent relationship was set
        #expect(addedBook.parent === document.root)
    }
    
    @Test func testRemoveChild() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Remove the magazine
        let magazine = document.root.children(where: { $0.name == "magazine" }).first!
        document.root.removeChild(magazine)
        
        // Verify it was removed
        #expect(document.root.childElements.count == 3)
        #expect(document.root.children(where: { $0.name == "magazine" }).isEmpty)
    }
    
    @Test func testRemoveChildAtIndex() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Remove the first book
        document.root.removeChild(at: 0)
        
        // Verify it was removed
        #expect(document.root.childElements.count == 3)
        
        // First child is now the second book
        let firstBook = document.root.childElements[0]
        let title = firstBook.query("title")[0].textContent
        #expect(title == "The Lord of the Rings")
    }
    
    @Test func testRemoveAllChildren() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Remove all children
        document.root.removeAllChildren()
        
        // Verify all children are removed
        #expect(document.root.childElements.isEmpty)
        #expect(document.root.children.isEmpty)
    }
    
    @Test func testSetContent() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Get the first title
        let title = document.root.descendants(where: { $0.name == "title" }).first!
        
        // Change its content
        title.setContent("New Title")
        
        // Verify content changed
        #expect(title.textNodes[0].text == "New Title")
    }
    
    @Test func testSetAttribute() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Get the first book
        let book = document.root.childElements[0]
        
        // Set an attribute
        book.setAttribute("bestseller", value: "false")
        book.setAttribute("new-attribute", value: "value")
        
        // Verify the attribute was set
        #expect(book.attributes["bestseller"] == "false")
        #expect(book.attributes["new-attribute"] == "value")
    }
    
    @Test func testRemoveAttribute() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Get the first book
        let book = document.root.childElements[0]
        
        // Remove an attribute
        book.removeAttribute("bestseller")
        
        // Verify the attribute was removed
        #expect(book.attributes["bestseller"] == nil)
    }
    
    @Test func testSetAttributes() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Get the first book
        let book = document.root.childElements[0]
        
        // Set multiple attributes
        book.setAttributes([
            "new-attribute1": "value1",
            "new-attribute2": "value2"
        ])
        
        // Verify the attributes were set
        #expect(book.attributes["new-attribute1"] == "value1")
        #expect(book.attributes["new-attribute2"] == "value2")
    }
    
    @Test func testRename() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Get the magazine
        let magazine = document.root.children(where: { $0.name == "magazine" }).first!
        
        // Rename it
        magazine.rename("journal")
        
        // Verify it was renamed
        #expect(magazine.name == "journal")
        #expect(document.root.children(where: { $0.name == "magazine" }).isEmpty)
        #expect(document.root.children(where: { $0.name == "journal" }).count == 1)
    }
    
    @Test func testCopy() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Get a book
        let book = document.root.childElements[0]
        
        // Copy the book
        let bookCopy = book.copy()
        
        // Verify it's a different instance
        #expect(bookCopy !== book)
        
        // Verify content is the same
        #expect(bookCopy.name == book.name)
        #expect(bookCopy.attributes["category"] == book.attributes["category"])
        #expect(bookCopy.childElements.count == book.childElements.count)
        
        // Add the copy to the root
        document.root.addChild(bookCopy)
        
        // Verify it was added
        #expect(document.root.childElements.count == 5)
        
        // Modify the copy
        bookCopy.setAttribute("modified", value: "true")
        
        // Original should be unchanged
        #expect(book.attributes["modified"] == nil)
    }
    
    @Test func testDocumentCopy() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Create a copy
        let copy = document.copy()
        
        // Verify it's a different instance
        #expect(copy !== document)
        
        // Verify content is the same
        #expect(copy.root.name == document.root.name)
        #expect(copy.root.childElements.count == document.root.childElements.count)
        
        // Modify the copy
        copy.root.setAttribute("modified", value: "true")
        
        // Original should be unchanged
        #expect(document.root.attributes["modified"] == nil)
    }
}