import Foundation
import XCTest

public enum TestingError: Error, CustomStringConvertible {

    case stub
    case genericErrorMessage(String)

    public var description: String {
        switch self {
        case .stub:
            return "Stub"
        case let .genericErrorMessage(message):
            return message
        }
    }

    public init(_ message: String) {
      self = .genericErrorMessage(message)
    }

    public init(_ message: String, query: XCUIElementQuery?, app: XCUIApplication = XCUIApplication()) {
        let message = message + " - query: [\(query.debugDescription)]. Full UI Tree: \(app.debugDescription)"
        self = .genericErrorMessage(message)
    }

    public init(_ message: String, element: XCUIElement, app: XCUIApplication = XCUIApplication()) {
        let message = message + " - element: [\(element.debugDescription)]. Full UI Tree: \(app.debugDescription)"
        self = .genericErrorMessage(message)
    }

    public static func wrap(_ error: Error) -> TestingError {
        if let testingError = error as? TestingError {
            return testingError
        }
        return TestingError("\(error)")
    }

    @discardableResult
    public func fail(
        file: StaticString=#file,
        line: UInt=#line
    ) -> TestingError {
        XCTFail(self.description, file: file, line: line)
        return self
    }
}
