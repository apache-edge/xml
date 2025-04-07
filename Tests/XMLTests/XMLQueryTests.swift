import Testing
@testable import XML

struct XMLQueryTests {
    
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
    
    func testBasicQuery() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Query all book elements
        let books = document.root.query("book")
        #expect(books.count == 3)
        #expect(books[0].name == "book")
        
        // Query all title elements
        let titles = document.root.query("title")
        #expect(titles.count == 0, "Direct child query should not find nested elements")
        
        // Query all titles under books
        let bookTitles = document.root.query("book/title")
        #expect(bookTitles.count == 3)
        #expect(bookTitles[0].textContent == "The Hitchhiker's Guide to the Galaxy")
        #expect(bookTitles[1].textContent == "The Lord of the Rings")
        #expect(bookTitles[2].textContent == "A Brief History of Time")
    }
    
    func testAttributeQuery() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Query books with category 'fiction'
        let fictionBooks = document.root.query("book[@category='fiction']")
        #expect(fictionBooks.count == 2)
        
        // Query books with bestseller attribute
        let bestsellerBooks = document.root.query("book[@bestseller]")
        #expect(bestsellerBooks.count == 2)
        
        // Query fiction books that are bestsellers
        let fictionBestsellers = document.root.query("book[@category='fiction'][@bestseller='true']")
        #expect(fictionBestsellers.count == 1)
        #expect(fictionBestsellers[0].query("title")[0].textContent == "The Hitchhiker's Guide to the Galaxy")
    }
    
    func testWildcardQuery() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Query all direct children
        let allChildren = document.root.query("*")
        #expect(allChildren.count == 4) // 3 books + 1 magazine
        
        // Query all publishers
        let publishers = document.root.query("*/publisher")
        #expect(publishers.count == 4)
    }
    
    func testQueryChaining() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Query fiction books
        let fictionBooks = document.root.query("book[@category='fiction']")
        
        // Chain query to get titles of fiction books
        let fictionTitles = fictionBooks.flatMap { $0.query("title") }
        #expect(fictionTitles.count == 2)
        #expect(fictionTitles[0].textContent == "The Hitchhiker's Guide to the Galaxy")
        #expect(fictionTitles[1].textContent == "The Lord of the Rings")
    }
    
    func testNestedQuery() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Query titles of books published before 1980
        let booksBefore1980 = document.root.query("book")
            .filter { book in
                if let yearElement = book.queryFirst("year"),
                   let year = Int(yearElement.textContent),
                   year < 1980 {
                    return true
                }
                return false
            }
            .flatMap { $0.query("title") }
            .map { $0.textContent }
        
        #expect(booksBefore1980.count == 2)
        #expect(booksBefore1980.contains("The Hitchhiker's Guide to the Galaxy"))
        #expect(booksBefore1980.contains("The Lord of the Rings"))
    }
    
    func testQueryFirst() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Query the first book
        let firstBook = document.root.queryFirst("book")
        #expect(firstBook != nil)
        #expect(firstBook?.attributes["category"] == "fiction")
        
        // Query a non-existent element
        let nonExistent = document.root.queryFirst("nonexistent")
        #expect(nonExistent == nil)
    }
    
    func testTextContentQuery() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Query books by author
        let douglasAdamsBook = document.root.query("book/author[text()='Douglas Adams']").flatMap { $0.parent != nil ? [$0.parent!] : [] }
        #expect(douglasAdamsBook.count == 1)
        #expect(douglasAdamsBook[0].queryFirst("title")?.textContent == "The Hitchhiker's Guide to the Galaxy")
    }
    
    func testParentQuery() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Get a title element
        let title = document.root.query("book/title")[0]
        
        // Get its parent (book)
        let book = title.parent
        #expect(book != nil)
        #expect(book?.name == "book")
        
        // Get book's parent (library)
        let library = book?.parent
        #expect(library != nil)
        #expect(library?.name == "library")
        
        // Library's parent should be nil (it's the root)
        #expect(library?.parent == nil)
    }
    
    func testMultiLevelQuery() async throws {
        let document = try XML.parse(string: xmlString)
        
        // Query the title of the non-fiction bestseller
        let nonFictionBestsellerTitle = document.root.query("book[@category='non-fiction'][@bestseller='true']/title")
        #expect(nonFictionBestsellerTitle.count == 1)
        #expect(nonFictionBestsellerTitle[0].textContent == "A Brief History of Time")
    }
}