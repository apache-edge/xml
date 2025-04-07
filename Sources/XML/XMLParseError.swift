import Foundation

/// Errors that can occur during XML parsing
public enum XMLParseError: Error, CustomStringConvertible {
    /// The XML is not well-formed
    case malformedXML(String)
    
    /// The XML has an invalid structure
    case invalidStructure(String)
    
    /// The XML contains invalid data
    case invalidData(String)
    
    /// The XML contains a syntax error
    case syntaxError(String)
    
    /// The XML has a premature end
    case unexpectedEnd(String)
    
    /// Other error
    case other(String)
    
    public var description: String {
        switch self {
        case .malformedXML(let message):
            return "Malformed XML: \(message)"
        case .invalidStructure(let message):
            return "Invalid structure: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .syntaxError(let message):
            return "Syntax error: \(message)"
        case .unexpectedEnd(let message):
            return "Unexpected end: \(message)"
        case .other(let message):
            return "XML error: \(message)"
        }
    }
}