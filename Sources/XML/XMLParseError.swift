#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Errors that can occur during XML parsing.
///
/// `XMLParseError` provides detailed information about why XML parsing failed,
/// categorizing issues into specific error types to help with debugging and error handling.
///
/// ## Error Types
///
/// The error enum includes several cases for different parsing problems:
///
/// - `malformedXML`: The XML structure doesn't follow proper XML syntax rules
/// - `invalidStructure`: The XML has structural issues like mismatched tags
/// - `invalidData`: The XML contains data that can't be properly interpreted
/// - `syntaxError`: There's a syntax issue in the XML
/// - `unexpectedEnd`: The XML document ends prematurely
/// - `other`: Any other parsing errors
///
/// ## Example Usage
///
/// ```swift
/// do {
///     let document = try XML.parse(string: xmlString)
///     // Process the document
/// } catch let error as XMLParseError {
///     switch error {
///     case .malformedXML(let message):
///         print("XML is malformed: \(message)")
///     case .invalidStructure(let message):
///         print("XML has structure issues: \(message)")
///     default:
///         print("Other parsing error: \(error)")
///     }
/// } catch {
///     print("Unexpected error: \(error)")
/// }
/// ```
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