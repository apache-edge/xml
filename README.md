# XML

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
- Minimal dependencies

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/apache-edge/xml.git", from: "1.0.0")
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

// Parse the XML
let document = try XMLDocument.parse(string: xmlString)

// Query elements
let books = document.root.query("book")
let fictionBooks = document.root.query("book[@category='fiction']")

// Traversal
let firstBook = document.root.firstChild(where: { $0.name == "book" })
let allAuthors = document.root.descendants(where: { $0.name == "author" })

// Get attribute or content
let category = firstBook?.attributes["category"]
let title = firstBook?.firstChild(where: { $0.name == "title" })?.content

// Mutation
let newBook = XMLElement(name: "book")
newBook.attributes["category"] = "science"
newBook.addChild(XMLElement(name: "title", content: "Cosmos"))
newBook.addChild(XMLElement(name: "author", content: "Carl Sagan"))
newBook.addChild(XMLElement(name: "year", content: "1980"))

document.root.addChild(newBook)

// Convert back to string
let updatedXML = document.xmlString
```

## Documentation

For full documentation, see [API Reference](https://apache-edge.github.io/xml/documentation/xml/).

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.