#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A simple XML parser that creates an XMLDocument from a string
public final class XMLParser {
    private let input: String
    private var position: String.Index
    private var lineNumber: Int = 1
    private var columnNumber: Int = 1
    
    /// Initialize a new parser with an XML string
    /// - Parameter string: The XML string to parse
    public init(string: String) {
        self.input = string
        self.position = string.startIndex
    }
    
    /// Parse the XML string into an XMLDocument
    /// - Returns: The parsed XMLDocument
    /// - Throws: XMLParseError if parsing fails
    public func parse() throws -> XMLDocument {
        // Skip whitespace
        skipWhitespace()
        
        // Parse XML declaration if present
        var version = "1.0"
        var encoding = "UTF-8"
        var declaration: XMLProcessingInstruction?
        
        if currentChar == "<" && peekNext() == "?" {
            let pi = try parseProcessingInstruction()
            if pi.target == "xml" {
                declaration = pi
                
                // Extract version and encoding
                let data = pi.data
                if let versionMatch = data.range(of: #"version\s*=\s*["']([^"']+)["']"#, options: .regularExpression) {
                    let versionString = data[versionMatch]
                    if let valueStart = versionString.range(of: #"["']([^"']+)"#, options: .regularExpression)?.upperBound,
                       let valueEnd = versionString.range(of: #"["']"#, options: .regularExpression, range: valueStart..<versionString.endIndex)?.lowerBound {
                        version = String(versionString[valueStart..<valueEnd])
                    }
                }
                
                if let encodingMatch = data.range(of: #"encoding\s*=\s*["']([^"']+)["']"#, options: .regularExpression) {
                    let encodingString = data[encodingMatch]
                    if let valueStart = encodingString.range(of: #"["']([^"']+)"#, options: .regularExpression)?.upperBound,
                       let valueEnd = encodingString.range(of: #"["']"#, options: .regularExpression, range: valueStart..<encodingString.endIndex)?.lowerBound {
                        encoding = String(encodingString[valueStart..<valueEnd])
                    }
                }
            }
        }
        
        // Parse processing instructions and comments before root
        var processingInstructions: [XMLProcessingInstruction] = []
        var comments: [XMLComment] = []
        
        skipWhitespace()
        
        while !isAtEnd {
            if currentChar == "<" {
                if peekNext() == "?" {
                    let pi = try parseProcessingInstruction()
                    processingInstructions.append(pi)
                } else if peekNext() == "!" && peek(offset: 2) == "-" && peek(offset: 3) == "-" {
                    let comment = try parseComment()
                    comments.append(comment)
                } else {
                    break
                }
            } else {
                break
            }
            
            skipWhitespace()
        }
        
        // Parse root element
        let root = try parseElement()
        
        // Create document
        let document = XMLDocument(root: root, version: version, encoding: encoding)
        
        // Set declaration, processing instructions, and comments
        if declaration != nil {
            document.declaration = declaration
        }
        
        if !processingInstructions.isEmpty {
            document.processingInstructions = processingInstructions
        }
        
        if !comments.isEmpty {
            document.comments = comments
        }
        
        // Skip trailing whitespace
        skipWhitespace()
        
        // Ensure we've reached the end
        if !isAtEnd {
            throw XMLParseError.malformedXML("Unexpected content after root element at line \(lineNumber), column \(columnNumber)")
        }
        
        return document
    }
    
    // MARK: - Parsing Methods
    
    private func parseElement() throws -> XMLElement {
        // Expect opening tag
        try expect("<")
        
        // Parse element name
        let name = try parseName()
        
        // Parse attributes
        let attributes = try parseAttributes()
        
        skipWhitespace()
        
        // Check if this is a self-closing tag
        if currentChar == "/" && peekNext() == ">" {
            advance()
            advance()
            return XMLElement(name: name, attributes: attributes)
        }
        
        // Expect end of opening tag
        try expect(">")
        
        // Create element
        let element = XMLElement(name: name, attributes: attributes)
        
        // Parse content
        var textContent = ""
        var hasTextContent = false
        
        while !isAtEnd {
            skipWhitespace()
            
            if isAtEnd {
                break
            }
            
            if currentChar == "<" {
                if peekNext() == "/" {
                    // Closing tag
                    break
                } else if peekNext() == "!" && peek(offset: 2) == "-" && peek(offset: 3) == "-" {
                    // Comment
                    let comment = try parseComment()
                    element.addChild(comment)
                } else if peekNext() == "!" && peek(offset: 2) == "[" && peek(offset: 3) == "C" {
                    // CDATA section
                    let cdata = try parseCData()
                    element.addChild(cdata)
                } else if peekNext() == "?" {
                    // Processing instruction
                    let pi = try parseProcessingInstruction()
                    element.addChild(pi)
                } else {
                    // Child element
                    if hasTextContent {
                        element.addChild(XMLText(text: textContent))
                        textContent = ""
                        hasTextContent = false
                    }
                    
                    let child = try parseElement()
                    element.addChild(child)
                }
            } else {
                // Text content
                let text = parseText()
                textContent += text
                hasTextContent = true
            }
        }
        
        // Add any remaining text content
        if hasTextContent {
            element.addChild(XMLText(text: textContent))
        }
        
        // Parse closing tag
        try expect("</")
        let closingName = try parseName()
        skipWhitespace()
        try expect(">")
        
        // Verify closing tag matches opening tag
        if name != closingName {
            throw XMLParseError.malformedXML("Mismatched tags: <\(name)> and </\(closingName)> at line \(lineNumber), column \(columnNumber)")
        }
        
        return element
    }
    
    private func parseAttributes() throws -> [String: String] {
        var attributes: [String: String] = [:]
        
        skipWhitespace()
        
        while !isAtEnd && currentChar != ">" && currentChar != "/" {
            let name = try parseName()
            skipWhitespace()
            
            try expect("=")
            
            skipWhitespace()
            
            // Parse attribute value
            let delimiter = currentChar
            if delimiter != "\"" && delimiter != "'" {
                throw XMLParseError.syntaxError("Expected attribute value to start with quote at line \(lineNumber), column \(columnNumber)")
            }
            
            advance()
            
            var value = ""
            while !isAtEnd && currentChar != delimiter {
                value.append(currentChar)
                advance()
            }
            
            if isAtEnd {
                throw XMLParseError.unexpectedEnd("Unterminated attribute value at line \(lineNumber), column \(columnNumber)")
            }
            
            advance() // Consume closing delimiter
            
            // Decode XML entities in the attribute value
            value = decodeXMLEntities(value)
            
            attributes[name] = value
            
            skipWhitespace()
        }
        
        return attributes
    }
    
    private func parseComment() throws -> XMLComment {
        try expect("<!--")
        
        var text = ""
        while !isAtEnd {
            if currentChar == "-" && peekNext() == "-" && peek(offset: 2) == ">" {
                break
            }
            text.append(currentChar)
            advance()
        }
        
        if isAtEnd {
            throw XMLParseError.unexpectedEnd("Unterminated comment at line \(lineNumber), column \(columnNumber)")
        }
        
        try expect("-->")
        
        return XMLComment(text: text)
    }
    
    private func parseCData() throws -> XMLCData {
        try expect("<![CDATA[")
        
        var text = ""
        while !isAtEnd {
            if currentChar == "]" && peekNext() == "]" && peek(offset: 2) == ">" {
                break
            }
            text.append(currentChar)
            advance()
        }
        
        if isAtEnd {
            throw XMLParseError.unexpectedEnd("Unterminated CDATA section at line \(lineNumber), column \(columnNumber)")
        }
        
        try expect("]]>")
        
        return XMLCData(text: text)
    }
    
    private func parseProcessingInstruction() throws -> XMLProcessingInstruction {
        try expect("<?")
        
        let target = try parseName()
        
        // Parse data
        skipWhitespace()
        
        var data = ""
        while !isAtEnd {
            if currentChar == "?" && peekNext() == ">" {
                break
            }
            data.append(currentChar)
            advance()
        }
        
        if isAtEnd {
            throw XMLParseError.unexpectedEnd("Unterminated processing instruction at line \(lineNumber), column \(columnNumber)")
        }
        
        try expect("?>")
        
        return XMLProcessingInstruction(target: target, data: data)
    }
    
    private func parseText() -> String {
        var text = ""
        
        while !isAtEnd && currentChar != "<" {
            text.append(currentChar)
            advance()
        }
        
        return decodeXMLEntities(text)
    }
    
    private func parseName() throws -> String {
        if isAtEnd || !isNameStartChar(currentChar) {
            throw XMLParseError.syntaxError("Expected XML name at line \(lineNumber), column \(columnNumber)")
        }
        
        var name = ""
        name.append(currentChar)
        advance()
        
        while !isAtEnd && isNameChar(currentChar) {
            name.append(currentChar)
            advance()
        }
        
        return name
    }
    
    // MARK: - Parser Utilities
    
    private var isAtEnd: Bool {
        position >= input.endIndex
    }
    
    private var currentChar: Character {
        guard !isAtEnd else {
            return "\0"
        }
        return input[position]
    }
    
    private func peekNext() -> Character {
        let nextIndex = input.index(after: position)
        guard nextIndex < input.endIndex else {
            return "\0"
        }
        return input[nextIndex]
    }
    
    private func peek(offset: Int) -> Character {
        guard let index = input.index(position, offsetBy: offset, limitedBy: input.endIndex) else {
            return "\0"
        }
        guard index < input.endIndex else {
            return "\0"
        }
        return input[index]
    }
    
    private func advance() {
        guard !isAtEnd else { return }
        
        if currentChar == "\n" {
            lineNumber += 1
            columnNumber = 1
        } else {
            columnNumber += 1
        }
        
        position = input.index(after: position)
    }
    
    private func skipWhitespace() {
        while !isAtEnd && currentChar.isWhitespace {
            advance()
        }
    }
    
    private func expect(_ expected: String) throws {
        for char in expected {
            if isAtEnd || currentChar != char {
                throw XMLParseError.syntaxError("Expected '\(expected)' at line \(lineNumber), column \(columnNumber)")
            }
            advance()
        }
    }
    
    private func isNameStartChar(_ char: Character) -> Bool {
        // According to XML 1.0 specification
        if char == ":" { return true }
        if char == "_" { return true }
        if char >= "A" && char <= "Z" { return true }
        if char >= "a" && char <= "z" { return true }
        
        // Unicode ranges are simplified here
        return false
    }
    
    private func isNameChar(_ char: Character) -> Bool {
        // According to XML 1.0 specification
        if isNameStartChar(char) { return true }
        if char == "-" { return true }
        if char == "." { return true }
        if char >= "0" && char <= "9" { return true }
        
        // Unicode combining characters and extenders are simplified here
        return false
    }
    
    private func decodeXMLEntities(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
    }
}