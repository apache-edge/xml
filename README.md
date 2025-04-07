# XML

[![Swift Tests](https://github.com/apache-edge/xml/actions/workflows/swift.yml/badge.svg)](https://github.com/apache-edge/xml/actions/workflows/swift.yml)
[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/apache-edge/xml/blob/main/LICENSE)
[![Version](https://img.shields.io/badge/Version-0.0.1-brightgreen.svg)](https://github.com/apache-edge/xml/releases/tag/0.0.1)

**Platforms:**
[![macOS](https://img.shields.io/badge/macOS-supported-brightgreen.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-supported-brightgreen.svg)](https://swift.org)
[![Linux](https://img.shields.io/badge/Linux-supported-brightgreen.svg)](https://swift.org)
[![Windows](https://img.shields.io/badge/Windows-supported-brightgreen.svg)](https://swift.org)
[![Android](https://img.shields.io/badge/Android-supported-brightgreen.svg)](https://swift.org)

A powerful, expressive, and comprehensive Swift 6 XML library for parsing, querying, traversing, and mutating XML documents.

## Features

- Parse XML from files or strings
- Construct XML documents programmatically
- Navigate XML structures with intuitive traversal APIs
- Query XML elements with XPath-like expressions
- Mutate XML content with a fluent API
- Comprehensive error handling
- Thread-safe operations
- Full Swift 6 compatibility
- Cross-platform support (macOS, iOS, tvOS, watchOS, visionOS, Linux)
- Minimal dependencies (automatically uses FoundationEssentials when available, falls back to Foundation)

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/apache-edge/xml.git", from: "0.0.1")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["XML"]
)
```

## Quick Start

Here are examples demonstrating the main features of the XML library:

### 1. Parsing XML

```swift
import XML

// Parse XML from a string
let xmlString = """
<library>
    <book category="fiction">
        <title>The Hitchhiker's Guide to the Galaxy</title>
        <author>Douglas Adams</author>
        <year>1979</year>
    </book>
    <book category="non-fiction">
        <title>A Brief History of Time</title>
        <author>Stephen Hawking</author>
        <year>1988</year>
    </book>
</library>
"""

// Parse the XML string
let document = try XML.parse(string: xmlString)

// Parse from a file
let fileURL = URL(fileURLWithPath: "/path/to/file.xml")
let documentFromFile = try XML.parse(contentsOf: fileURL)

// Access the root element
let rootElement = document.root
print("Root element name: \(rootElement.name)") // "library"
```

### 2. Querying and Traversing

```swift
// Query elements using XPath-like expressions
let books = document.root.query("book")
print("Number of books: \(books.count)") // 2

// Query with attribute filters
let fictionBooks = document.root.query("book[@category='fiction']")
let nonFictionBooks = document.root.query("book[@category='non-fiction']")

// Query with multiple levels
let titles = document.root.query("book/title")
let fictionTitles = document.root.query("book[@category='fiction']/title")

// Get element content
if let firstTitle = titles.first {
    print("First title: \(firstTitle.content ?? "")") // "The Hitchhiker's Guide to the Galaxy"
}

// Traversal methods
// Get first child matching a condition
let firstBook = document.root.firstChild(where: { $0.name == "book" })

// Get all descendants matching a condition
let allAuthors = document.root.descendants(where: { $0.name == "author" })
allAuthors.forEach { author in
    print("Author: \(author.content ?? "")")
}

// Navigate parent-child relationships
if let firstBook = books.first {
    let parent = firstBook.parent // The library element
    let children = firstBook.children // title, author, year elements
    let childElements = firstBook.childElements // Same as children but only XMLElement types
}
```

### 3. Building XML from Scratch

```swift
// Create a new document with a root element
let catalog = XMLDocument(root: XMLElement(name: "catalog"))

// Method 1: Add elements individually
let product = XMLElement(name: "product")
product.attributes["id"] = "1001"
product.addChild(XMLElement(name: "name", content: "Coffee Maker"))
product.addChild(XMLElement(name: "price", content: "49.99"))
product.addChild(XMLElement(name: "available", content: "true"))

catalog.root.addChild(product)

// Method 2: Use the fluent builder API
let anotherProduct = XMLElement(name: "product")
    .setAttribute("id", value: "1002")
    .addChild(XMLElement(name: "name", content: "Toaster"))
    .addChild(XMLElement(name: "price", content: "29.99"))
    .addChild(XMLElement(name: "available", content: "true"))

catalog.root.addChild(anotherProduct)

// Method 3: Use the closure-based builder
let thirdProduct = XMLElement.build("product") { product in
    product.setAttribute("id", value: "1003")
    
    product.addChild(XMLElement.build("name") { name in
        name.setContent("Blender")
    })
    
    product.addChild(XMLElement.build("price") { price in
        price.setContent("39.99")
    })
    
    product.addChild(XMLElement(name: "available", content: "false"))
}

catalog.root.addChild(thirdProduct)

// Generate XML string (compact format)
let xmlOutput = catalog.xmlString
print(xmlOutput)

// Generate XML with pretty formatting (indented)
let prettyXML = catalog.xmlStringFormatted(pretty: true)
print(prettyXML)
```

### 4. Manipulating XML

```swift
// Starting with our library document from the parsing example
let document = try XML.parse(string: xmlString)

// 1. Adding new elements
let newBook = XMLElement(name: "book")
newBook.attributes["category"] = "science"
newBook.addChild(XMLElement(name: "title", content: "Cosmos"))
newBook.addChild(XMLElement(name: "author", content: "Carl Sagan"))
newBook.addChild(XMLElement(name: "year", content: "1980"))

document.root.addChild(newBook)

// 2. Updating elements
let books = document.root.query("book")
if let firstBook = books.first {
    // Update an attribute
    firstBook.setAttribute("category", value: "science-fiction")
    
    // Update content
    if let yearElement = firstBook.firstChild(where: { $0.name == "year" }) {
        yearElement.setContent("1979 (First Edition)")
    }
    
    // Add a new child element
    firstBook.addChild(XMLElement(name: "publisher", content: "Pan Books"))
}

// 3. Removing elements
if books.count > 2 {
    // Remove the third book
    if let thirdBook = books[safe: 2] {
        thirdBook.removeFromParent()
    }
}

// Remove all books with a specific category
let scienceBooks = document.root.query("book[@category='science']")
scienceBooks.forEach { book in
    book.removeFromParent()
}

// Remove specific child elements
if let firstBook = books.first {
    // Remove all publisher elements from the first book
    firstBook.children.filter { $0.name == "publisher" }.forEach { $0.removeFromParent() }
    
    // Or alternatively:
    firstBook.removeChildren(where: { $0.name == "publisher" })
}

// 4. Renaming elements
if let firstBook = books.first {
    firstBook.name = "novel"
}

// Generate the updated XML
let updatedXML = document.xmlStringFormatted(pretty: true)
print(updatedXML)
```

## Running the Examples

This repository includes a complete example application that demonstrates the key features of the XML library.

### Example File

The [Sources/XMLExample/main.swift](https://github.com/apache-edge/xml/blob/main/Sources/XMLExample/main.swift) file contains three practical examples:

1. **Parsing XML** - Shows how to parse an XML string and extract data using queries
2. **Creating XML** - Demonstrates building a new XML document using the fluent builder API
3. **Modifying XML** - Illustrates how to update an existing XML document by adding and modifying elements

### Running the Example

After cloning the repository, you can run the example application with:

```bash
# Clone the repository
git clone https://github.com/apache-edge/xml.git
cd xml

# Run the example
swift run XMLExample
```

The example will output the results of all three demonstrations, showing the XML library in action.

## Design Decisions

### Classes vs Structs vs NonCopyable Types

This library uses classes for XML nodes rather than structs or Swift's newer NonCopyable types. This decision was made for several important reasons:

#### Why Classes?

1. **Tree Structure Representation**: XML is inherently a tree structure with bidirectional references (children know their parents and vice versa). Reference semantics provided by classes make these relationships easier to maintain.

2. **Node Identity**: In XML processing, node identity is crucial when querying or modifying specific nodes. Classes provide natural identity semantics where two variables can reference the same underlying node.

3. **Mutable State**: XML documents are frequently modified after creation (adding children, changing attributes, etc.). Classes allow multiple references to the same node to see changes consistently.

4. **Performance Considerations**: For large XML documents, copying entire trees (as would happen with structs) would be inefficient in both memory usage and processing time.

5. **API Consistency**: The parent-child relationship is more intuitive with reference semantics, as modifications to a node are visible to all code holding a reference to that node.

#### Why Not Structs?

While Swift structs offer many advantages for other use cases, they present challenges for XML representation:

1. **Copy Overhead**: Structs would require copying entire subtrees when passing XML nodes around, which would be expensive for large documents.

2. **Parent-Child Complexity**: Maintaining bidirectional parent-child relationships is difficult with value semantics, requiring complex reference management.

3. **Unexpected Behavior**: Value semantics could lead to surprising behavior where changes to a "copy" of a node wouldn't affect the original document.

#### Why Not NonCopyable Types?

Swift's newer NonCopyable types offer interesting ownership semantics but aren't ideal for this library:

1. **API Flexibility**: NonCopyable types would impose significant constraints on how users can work with XML nodes.

2. **Compatibility**: Using NonCopyable types would require Swift 5.9+, potentially limiting adoption.

3. **Familiar Patterns**: Classes provide well-understood semantics that align with how developers typically expect to work with tree structures.

This design choice prioritizes intuitive API design, performance for large documents, and alignment with the natural structure of XML data.

## Documentation

The library includes comprehensive DocC documentation with:

- Detailed API reference for all types and methods
- Code examples for common tasks
- Tutorial articles on parsing, querying, building, and serializing XML
- Syntax guides for the XPath-like query language

To generate and view the documentation:

```bash
# Generate documentation
swift package generate-documentation

# Preview documentation
swift package preview-documentation
```

For online documentation, see [API Reference](https://apache-edge.github.io/xml/documentation/xml/).

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.