import Foundation

/// Represents an XML document with a root element
public final class XMLDocument {
    /// The XML version
    public let version: String
    
    /// The XML encoding
    public let encoding: String
    
    /// The root element of the document
    public let root: XMLElement
    
    /// The XML declaration
    public var declaration: XMLProcessingInstruction?
    
    /// Any processing instructions before the root element
    public var processingInstructions: [XMLProcessingInstruction]
    
    /// Any comments before the root element
    public var comments: [XMLComment]
    
    /// Creates a new XML document
    /// - Parameters:
    ///   - root: The root element
    ///   - version: The XML version, defaults to "1.0"
    ///   - encoding: The XML encoding, defaults to "UTF-8"
    public init(root: XMLElement, version: String = "1.0", encoding: String = "UTF-8") {
        self.root = root
        self.version = version
        self.encoding = encoding
        self.processingInstructions = []
        self.comments = []
        
        self.declaration = XMLProcessingInstruction(
            target: "xml",
            data: "version=\"\(version)\" encoding=\"\(encoding)\""
        )
    }
    
    /// Adds a processing instruction to the document
    /// - Parameter instruction: The processing instruction to add
    /// - Returns: Self for method chaining
    @discardableResult
    public func addProcessingInstruction(_ instruction: XMLProcessingInstruction) -> Self {
        processingInstructions.append(instruction)
        return self
    }
    
    /// Adds a comment to the document
    /// - Parameter comment: The comment to add
    /// - Returns: Self for method chaining
    @discardableResult
    public func addComment(_ comment: XMLComment) -> Self {
        comments.append(comment)
        return self
    }
    
    /// The XML string representation of this document
    public var xmlString: String {
        var result = ""
        
        // Add XML declaration
        if let declaration = declaration {
            result += declaration.xmlString + "\n"
        }
        
        // Add processing instructions
        for instruction in processingInstructions {
            result += instruction.xmlString + "\n"
        }
        
        // Add comments
        for comment in comments {
            result += comment.xmlString + "\n"
        }
        
        // Add root element
        result += root.xmlString
        
        return result
    }
    
    /// Creates a deep copy of this document
    /// - Returns: A new XMLDocument with copies of all nodes
    public func copy() -> XMLDocument {
        let rootCopy = root.copy()
        let copy = XMLDocument(root: rootCopy, version: version, encoding: encoding)
        
        copy.processingInstructions = processingInstructions.map { 
            XMLProcessingInstruction(target: $0.target, data: $0.data) 
        }
        
        copy.comments = comments.map { 
            XMLComment(text: $0.text) 
        }
        
        return copy
    }
}

// MARK: - Parsing
extension XMLDocument {
    /// Parse XML from a string
    /// - Parameter string: The XML string to parse
    /// - Returns: A new XMLDocument
    /// - Throws: XMLParseError if parsing fails
    public static func parse(string: String) throws -> XMLDocument {
        let parser = XMLParser(string: string)
        return try parser.parse()
    }
    
    /// Parse XML from a file
    /// - Parameter url: The URL of the file to parse
    /// - Returns: A new XMLDocument
    /// - Throws: XMLParseError if parsing fails or the file can't be read
    public static func parse(contentsOf url: URL) throws -> XMLDocument {
        let data = try Data(contentsOf: url)
        guard let string = String(data: data, encoding: .utf8) else {
            throw XMLParseError.invalidData("Could not decode data as UTF-8")
        }
        return try parse(string: string)
    }
    
    /// Parse XML from a file path
    /// - Parameter path: The path to the file to parse
    /// - Returns: A new XMLDocument
    /// - Throws: XMLParseError if parsing fails or the file can't be read
    public static func parse(contentsOfFile path: String) throws -> XMLDocument {
        let url = URL(fileURLWithPath: path)
        return try parse(contentsOf: url)
    }
}

// MARK: - Writing
extension XMLDocument {
    /// Writes the XML to a file
    /// - Parameter url: The URL to write to
    /// - Throws: Error if writing fails
    public func write(to url: URL) throws {
        let data = xmlString.data(using: .utf8)!
        try data.write(to: url)
    }
    
    /// Writes the XML to a file path
    /// - Parameter path: The path to write to
    /// - Throws: Error if writing fails
    public func write(toFile path: String) throws {
        let url = URL(fileURLWithPath: path)
        try write(to: url)
    }
}