import Foundation

public enum StringComparison : CustomStringConvertible, Equatable {
    case contains(String)
    case exactMatch(String)
    case dontCheck
    
    public var description: String {
        switch (self) {
            case .contains:
                return "contain"
            
            case .exactMatch:
                return "exactly match"
            
            case .dontCheck:
                return "not check"
        }
    }
    
    public func compare(name:String, value:String) throws {
        switch (self) {
            case let .contains(expected):
                if !value.contains(expected) {
                    throw makeTestingError(name:name, value:value, expected:expected)
                }
            
            case let .exactMatch(expected):
                if value != expected {
                    throw makeTestingError(name:name, value:value, expected:expected)
                }
            
            case .dontCheck:
                break
        }
    }
    
    public func makeTestingError(name:String, value:String, expected:String) -> TestingError {
        let expectedWithNewlinesReplaced = expected.replacingOccurrences(of: "\n", with: "\\n")
        let valueWithNewlinesReplaced = value.replacingOccurrences(of: "\n", with: "\\n")
        let message = "Expected \(name):\n🟢\(valueWithNewlinesReplaced)🛑\n\n to \(self.description):\n 🟢\(expectedWithNewlinesReplaced)🛑"
        return TestingError(message)
    }
}
