import Foundation

/// Provides XPath-like query functionality for XML elements
public enum XMLQuery {
    /// Executes a query on an element
    /// - Parameters:
    ///   - query: The query string
    ///   - element: The element to query
    /// - Returns: Array of matching elements
    public static func execute(query: String, on element: XMLElement) -> [XMLElement] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle absolute paths starting with /
        if normalizedQuery.hasPrefix("/") {
            var rootElement = element
            while let parent = rootElement.parent {
                rootElement = parent
            }
            
            if normalizedQuery == "/" {
                return [rootElement]
            }
            
            let subpath = String(normalizedQuery.dropFirst())
            return executeRelativeQuery(query: subpath, on: rootElement)
        }
        
        return executeRelativeQuery(query: normalizedQuery, on: element)
    }
    
    private static func executeRelativeQuery(query: String, on element: XMLElement) -> [XMLElement] {
        // Split the query by slashes to get the path segments
        let segments = query.split(separator: "/")
        
        if segments.isEmpty {
            return []
        }
        
        // Start with the current element
        var results: [XMLElement] = [element]
        
        for segment in segments {
            let segmentStr = String(segment)
            results = processQuerySegment(segmentStr, elements: results)
            
            if results.isEmpty {
                return []
            }
        }
        
        return results
    }
    
    private static func processQuerySegment(_ segment: String, elements: [XMLElement]) -> [XMLElement] {
        var results: [XMLElement] = []
        
        // Special case for wildcard
        if segment == "*" {
            for element in elements {
                results.append(contentsOf: element.childElements)
            }
            return results
        }
        
        // Special case for .. (parent)
        if segment == ".." {
            for element in elements {
                if let parent = element.parent {
                    results.append(parent)
                }
            }
            return results
        }
        
        // Special case for . (self)
        if segment == "." {
            return elements
        }
        
        // Special case for // (descendants)
        if segment == "//" {
            var descendants: [XMLElement] = []
            for element in elements {
                descendants.append(contentsOf: element.descendants(where: { _ in true }))
            }
            return descendants
        }
        
        // Check if we have predicates
        if segment.contains("[") && segment.contains("]") {
            // Split the segment into name and predicate
            guard let openBracketIndex = segment.firstIndex(of: "["),
                  let closeBracketIndex = segment.lastIndex(of: "]"),
                  openBracketIndex < closeBracketIndex else {
                return []
            }
            
            let name = String(segment[..<openBracketIndex])
            let predicate = String(segment[segment.index(after: openBracketIndex)..<closeBracketIndex])
            
            // First, filter by name
            var matchingByName: [XMLElement] = []
            for element in elements {
                if name == "*" {
                    matchingByName.append(contentsOf: element.childElements)
                } else {
                    matchingByName.append(contentsOf: element.children(where: { $0.name == name }))
                }
            }
            
            // Apply predicate
            return applyPredicate(predicate, to: matchingByName)
        }
        
        // Simple name matching
        for element in elements {
            results.append(contentsOf: element.children(where: { $0.name == segment }))
        }
        
        return results
    }
    
    private static func applyPredicate(_ predicate: String, to elements: [XMLElement]) -> [XMLElement] {
        // Handle index predicate (e.g., [1], [2], etc.)
        if let index = Int(predicate) {
            // XML uses 1-based indexing in XPath
            let adjustedIndex = index - 1
            if adjustedIndex >= 0 && adjustedIndex < elements.count {
                return [elements[adjustedIndex]]
            }
            return []
        }
        
        // Handle attribute predicate (e.g., [@attribute='value'])
        if predicate.hasPrefix("@") {
            let attrPredicate = String(predicate.dropFirst())
            
            // Handle attribute existence check (e.g., [@attribute])
            if !attrPredicate.contains("=") {
                return elements.filter { $0.attributes.keys.contains(attrPredicate) }
            }
            
            // Handle attribute value check (e.g., [@attribute='value'])
            let components = attrPredicate.split(separator: "=", maxSplits: 1)
            guard components.count == 2 else { return [] }
            
            let attributeName = String(components[0])
            var attributeValue = String(components[1])
            
            // Remove quotes
            if (attributeValue.hasPrefix("'") && attributeValue.hasSuffix("'")) ||
               (attributeValue.hasPrefix("\"") && attributeValue.hasSuffix("\"")) {
                attributeValue = String(attributeValue.dropFirst().dropLast())
            }
            
            return elements.filter { element in
                if let value = element.attributes[attributeName] {
                    return value == attributeValue
                }
                return false
            }
        }
        
        // Handle text content predicate (e.g., [text()='value'])
        if predicate.hasPrefix("text()") && predicate.contains("=") {
            let components = predicate.split(separator: "=", maxSplits: 1)
            guard components.count == 2 else { return [] }
            
            var textValue = String(components[1])
            
            // Remove quotes
            if (textValue.hasPrefix("'") && textValue.hasSuffix("'")) ||
               (textValue.hasPrefix("\"") && textValue.hasSuffix("\"")) {
                textValue = String(textValue.dropFirst().dropLast())
            }
            
            return elements.filter { element in
                let elementText = element.textContent
                return elementText == textValue
            }
        }
        
        // Unsupported predicate
        return []
    }
}