# XML

[![Swift Tests](https://github.com/apache-edge/xml/actions/workflows/swift.yml/badge.svg)](https://github.com/apache-edge/xml/actions/workflows/swift.yml)
[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/apache-edge/xml/blob/main/LICENSE)

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

// Convert back to string (compact format)
let updatedXML = document.xmlString

// Convert with pretty formatting (indented)
let prettyXML = document.xmlStringFormatted(pretty: true)
```

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