import Foundation
import XCTest
import RegexBuilder

public struct XCUIElementProxy {
    public var identifier: String?
    public var label: String?
    public var value: String?
    public var xcUiElementType: String
    public var frame: CGRect
    public var depth: Int
}

@available(iOS 16, *)
public class XCUIElementProxyFactory {
    static let singleton = XCUIElementProxyFactory()

    let regexLeadingWhitespace = Regex {
        Anchor.startOfLine
        Capture {
            OneOrMore(.whitespace, .eager)
        }
    }
    
    let regexIndentAndType = Regex {
        Anchor.startOfLine
        
        Capture() {
            OneOrMore(.digit)
        } transform: {Int($0) ?? 0}
        
        ", "
        
        Capture() {
            OneOrMore(.any, .reluctant)
        } transform: { String($0) }
        
        ", "
    }

    let regexFrame = Regex {
        Capture {
            "{{"
            OneOrMore(.any, .reluctant)
            "}}"
        } transform: {String($0)}
    }

    let regexIdentifier = Regex {
        ", identifier: '"
        Capture() {
            OneOrMore(.any, .reluctant)
        } transform: {String($0)}
        "'"
    }

    let regexLabel = Regex {
        "label: '"
        Capture() {
            OneOrMore(.any, .reluctant)
        } transform: {String($0)}
        "'"
    }

    let regexValue = Regex {
        "value: "
        Capture{
            OneOrMore(.any, .reluctant)
        } transform: {String($0)}
        Anchor.endOfLine
    }

    func parse(debugDescription: String) -> [XCUIElementProxy] {

        debugDescription
        
        // Remove wrapper
        .substring(from: "Element subtree:\n", to: "\nPath to element:")

        // If nil, default to ""
        .defaultValue("")

        // Replace the → on the Application
        .replacingOccurrences(of: "→", with: " ")

        // Compact labels into a single line
        .transformBetween(startToken: "label: '", endToken: "'") {
            $0.replacingOccurrences(of: "\n", with: "\\n")
        }

        // Replace the indent with an int representing the indent level
        .replacing(regexLeadingWhitespace, with: { match in
            let leadingSpaces = String(match.output.1)
            let length = leadingSpaces.count
            let indentLevel = Int(length / 2) - 1
            return "\(indentLevel), "
        })
        .split(separator: "\n")
        .map(String.init)
        .compactMap(parse(line:))
    }

    private func parse(line: String) -> XCUIElementProxy? {

        // Mut always have indent and type
        guard let regexMatchIndentAndType = line.firstMatch(of: regexIndentAndType) else {
            print("🚨 could not parse line: \(line)")
            return nil
        }
        
        let indent = regexMatchIndentAndType.output.1
        let type = regexMatchIndentAndType.output.2
        let frame = parse(strFrame: line.firstMatch(of: regexFrame)?.output.1)
        let label = line.firstMatch(of: regexLabel)?.output.1
        let identifier = line.firstMatch(of: regexIdentifier)?.output.1
        let value = line.firstMatch(of: regexValue)?.output.1
        
        return XCUIElementProxy(
            identifier: identifier,
            label: label,
            value: value,
            xcUiElementType: type,
            frame: frame,
            depth: indent
        )
    }

    // Convert frame format of {{20.0, 452.0}, {334.0, 357.0}} to a CGRect
    private func parse(strFrame: String?) -> CGRect {
        guard let strFrame else {
            return CGRectNull
        }
        
        let arrCgFloat:[CGFloat] = strFrame
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .split(separator: ", ")
            .compactMap {
                guard let double = Double($0) else {
                    return nil
                }
                
                return CGFloat(double)
            }
            
        guard arrCgFloat.count == 4 else {
            return CGRectNull
        }
            
        return CGRect(
            x: arrCgFloat[0],
            y: arrCgFloat[1],
            width: arrCgFloat[2],
            height: arrCgFloat[3]
        )
        
    }
    
}
