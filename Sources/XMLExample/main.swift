import Foundation
import XML

// Example 1: Parse an XML string
func example1() throws {
    print("\nExample 1: Parse XML from a string")
    
    let xmlString = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!-- This is a sample XML document -->
    <library>
        <book category="fiction" bestseller="true">
            <title>The Hitchhiker's Guide to the Galaxy</title>
            <author>Douglas Adams</author>
            <year>1979</year>
        </book>
        <book category="non-fiction">
            <title>A Brief History of Time</title>
            <author>Stephen Hawking</author>
            <year>1988</year>
            <![CDATA[<description>A landmark volume in science</description>]]>
        </book>
    </library>
    """
    
    // Parse the XML
    let document = try XML.parse(string: xmlString)
    
    // Get all books
    let books = document.root.query("book")
    print("Found \(books.count) books:")
    
    // Process each book
    for (index, book) in books.enumerated() {
        let title = book.query("title").first?.textContent ?? "Unknown"
        let author = book.query("author").first?.textContent ?? "Unknown"
        let year = book.query("year").first?.textContent ?? "Unknown"
        let category = book.attributes["category"] ?? "Unknown"
        let isBestseller = book.attributes["bestseller"] == "true"
        
        print("\nBook #\(index + 1):")
        print("  Title: \(title)")
        print("  Author: \(author)")
        print("  Year: \(year)")
        print("  Category: \(category)")
        print("  Bestseller: \(isBestseller ? "Yes" : "No")")
    }
}

// Example 2: Create XML using the builder
func example2() {
    print("\nExample 2: Create XML using the builder")
    
    // Create a document using the builder
    let builder = XML.build(root: "contacts")
        .documentComment("Contact list")
        .element(name: "person", attributes: ["id": "1"])
            .element(name: "n", content: "John Doe")
            .parent()
            .element(name: "email", content: "john@example.com")
            .parent()
            .element(name: "phone", attributes: ["type": "mobile"], content: "555-123-4567")
            .parent()
        .parent()
        .element(name: "person", attributes: ["id": "2"])
            .element(name: "n", content: "Jane Smith")
            .parent()
            .element(name: "email", content: "jane@example.com")
            .parent()
            .element(name: "phone", attributes: ["type": "work"], content: "555-987-6543")
            .parent()
        .parent()
    
    let document = builder.xmlDocument
    
    // Print the XML with pretty formatting
    print(document.xmlStringFormatted(pretty: true))
}

// Example 3: Modify existing XML
func example3() throws {
    print("\nExample 3: Modify existing XML")
    
    // Start with a simple XML
    let xmlString = """
    <products>
        <product id="1">
            <name>Widget</name>
            <price>19.99</price>
            <inStock>true</inStock>
        </product>
    </products>
    """
    
    // Parse the XML
    let document = try XML.parse(string: xmlString)
    
    // Find the products element
    let products = document.root
    
    // Add a new product
    let newProduct = XML.element(name: "product", attributes: ["id": "2"])
    
    // Create child elements with explicit content
    let nameElement = XML.element(name: "n")
    nameElement.setContent("Gadget")
    newProduct.addChild(nameElement)
    
    let priceElement = XML.element(name: "price")
    priceElement.setContent("24.99")
    newProduct.addChild(priceElement)
    
    let inStockElement = XML.element(name: "inStock")
    inStockElement.setContent("false")
    newProduct.addChild(inStockElement)
    
    products.addChild(newProduct)
    
    // Update the price of the first product
    if let firstProduct = products.query("product").first,
       let price = firstProduct.query("price").first {
        price.removeAllChildren() // Remove all existing children first
        price.addChild(XML.text("21.99")) // Add new price as a text node
    }
    
    // Print the modified XML with pretty formatting
    print(document.xmlStringFormatted(pretty: true))
}

// Run all examples
func runAllExamples() {
    print("XML Library Examples")
    print("===================")
    
    do {
        try example1()
        example2()
        try example3()
    } catch {
        print("Error: \(error)")
    }
}

// Run the examples
runAllExamples()