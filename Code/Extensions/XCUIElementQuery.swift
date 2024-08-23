import Foundation
import XCTest

public extension XCUIElementQuery {
    var placeholders: [Placeholder] {
        return allElementsBoundByIndex.placeholders
    }

    // Unlike the built-in XCUIElement.tap(), this XCUIElementQuery version uses WaitFor to gracefully
    // attempt taps and allows XCTFails to be targetted to specific file/line locations.
    func tap(
        label: String,
        recordFailures: Bool = true,
        checkForHittable: Bool = true,
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        file: StaticString=#file,
        line: UInt=#line
    ) {
        let result = WaitFor.result(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts
        ) {
            let element = self[label].firstMatch

            // Optionally skip the hittable check. This is nice if the element is offscreen in
            // a scrollview as element.tap() will immediately scroll to it.
            if checkForHittable {
                guard element.isHittable else {
                    throw TestingError("Label [\(label)] not hittable", query: self)
                }
            } else {
                guard element.exists else {
                    throw TestingError("Label [\(label)] doesn't exist", query: self)
                }
            }

            element.tap()
        }

        if recordFailures {
            result.error?.fail(file: file, line: line)
        }
    }

    func waitForContains(
        text: String,
        recordFailures: Bool = true,
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        testDescription: String? = nil,
        file: StaticString=#file,
        line: UInt=#line
    ) {
        let result = WaitFor.result(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts
        ) {
            let predicate = NSPredicate(format: "label CONTAINS[c] '\(text)'")
            let refinedQuery = self.containing(predicate)
            let element = refinedQuery.firstMatch
            guard element.exists else {
                var message = "Text [\(text)] not found in query: \n[\(self.debugDescription)]"
                if let testDescription = testDescription {
                    message += " \(testDescription)"
                }
                throw TestingError(message)
            }
        }

        if recordFailures {
            result.error?.fail(file: file, line: line)
        }
    }
    
    func waitForNotEmpty(
        message:String,
        file:StaticString=#file,
        line:UInt=#line
    ) {
        
        let query = self
        let result = WaitFor.result {
            if (query.count == 0) {
                throw TestingError(message)
            }
        }
        
        result.error?.fail(file: file, line: line)
    }
}
