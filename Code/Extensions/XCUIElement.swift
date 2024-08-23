import Foundation
import XCTest

// MARK: XCUIElementProxy
public extension XCUIElement {
    @available(iOS 16, *)
    var debugDescriptionProxies: [XCUIElementProxy] {
        XCUIElementProxyFactory.singleton.parse(debugDescription: debugDescription)
    }
    
    @available(iOS 16, *)
    var debugDescriptionProxiesString: String {
        debugDescriptionProxies.map {
            "\($0)"
        }.joined(separator: "\n")
    }
}

// MARK: Text
public extension XCUIElement {
    
    func getStringValue(
        file:StaticString=#file,
        line:UInt=#line
    ) -> String {
        guard let ret = self.value as? String else {
            XCTFail("Value is nil", file:file, line:line)
            return ""
        }
        
        return ret
    }
    
    func clearAndEnterText(
        _ newValue: String,
        _ tapClearButton: Bool = true,
        app: XCUIApplication = XCUIApplication(),
        file: StaticString=#file,
        line: UInt=#line
    ) {
        self.assertExists(file: file, line: line)
        guard let currentValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value: \(self)")
            return
        }

        guard currentValue != newValue else {
            return
        }

        guard currentValue != "" else {
            // Tap the element to scroll to it
            self.tap()
            
            // Enter the text
            self.typeText(newValue + "\n")
            return
        }
        
        if tapClearButton, self.buttons.firstMatch.exists {
            // Tap the clear button
            self.buttons.firstMatch.tap()
            
            // Enter the text
            self.typeText(newValue + "\n")
        } else {
            
            // Hit the delete key enough times to delete the current text
            var deleteString = ""
            for _ in currentValue {
                deleteString += XCUIKeyboardKey.delete.rawValue
            }

            self.assertHittable(file: file, line: line)

            let lowerRightCorner = self.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.9))
            lowerRightCorner.tap()

            self.assertHasKeyboardFocus(app: app, file: file, line: line)
            self.typeText(deleteString + newValue + "\n")

            return
        }

    }

    // MARK: Keyboard Focus
    var hasKeyboardFocus: Bool {
        let hasKeyboardFocus = (self.value(forKey: "hasKeyboardFocus") as? Bool) ?? false
        return hasKeyboardFocus
    }

    func assertHasKeyboardFocus(
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        app: XCUIApplication = XCUIApplication(),
        file: StaticString=#file,
        line: UInt=#line
    ) {
        let element = self
        WaitFor.tryThrows(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts,
            file: file,
            line: line
        ) {
            if !element.hasKeyboardFocus {
                throw TestingError("Element \(element) does not have keyboard focus", element: element, app: app)
            }
        }
    }
}

// MARK: Checks & Assertions
public extension XCUIElement {
    /*
     Hittable returns YES if the element exists and can be clicked, tapped, or pressed at its current location. It
     returns NO for an offscreen element in a scrollable view, even if the element would be scrolled into a hittable
     position by calling click tap, or another hit-point-related interaction method.
     */
    func assertHittable(
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        app: XCUIApplication = XCUIApplication(),
        file: StaticString=#file,
        line: UInt=#line
    ) {
        let element = self
        WaitFor.tryThrows(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts,
            file: file,
            line: line
        ) {
            if !element.waitForExistence(timeout: 0) {
                throw TestingError("Doesn't exist", element: self, app: app)
            }
            
            if !element.isHittable {
                throw TestingError("Not hittable", element: self, app: app)
            }
        }
    }
    
    func assertExists(
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        app: XCUIApplication = XCUIApplication(),
        file: StaticString=#file,
        line: UInt=#line
    ) {
        let element = self
        WaitFor.tryThrows(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts,
            file: file,
            line: line
        ) {
            if !element.exists {
                throw TestingError("Does not exist", element: self, app: app)
            }
        }
    }
    
    func checkExists(
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        app: XCUIApplication = XCUIApplication()
    ) -> Bool {
        let element = self
        return WaitFor.bool(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts
        ) {
            if !element.exists {
                throw TestingError("Does not exist", element: self, app: app)
            }
        }
    }
    
    func assertNotExists(
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        app: XCUIApplication = XCUIApplication(),
        file: StaticString=#file,
        line: UInt=#line
    ) {
        let element = self
        WaitFor.tryThrows(
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts,
            file: file,
            line: line
        ) {
            if element.exists {
                throw TestingError("Element \(element) exists", element: element, app: app)
            }
        }
    }
    
    func assertFrameSizeEquals(
        size:CGSize,
        waitPerAttempt: TimeInterval = WaitFor.defaultWaitPerAttempt,
        totalNumberOfAttempts: Int = WaitFor.defaultTotalNumberOfAttempts,
        app: XCUIApplication = XCUIApplication(),
        file: StaticString=#file,
        line: UInt=#line
    ) {
        let element = self
        WaitFor.tryThrows (
            waitPerAttempt: waitPerAttempt,
            totalNumberOfAttempts: totalNumberOfAttempts,
            file: file,
            line: line
        ) {
            if (!element.exists) {
                throw TestingError(
                    "Element \(element) does not exist",
                    element: element,
                    app: app
                )
            }
            
            let elementSize = element.frame.size
            if (element.frame.size != size) {
                throw TestingError(
                    "Element size of \(elementSize) is not equal to expected size of \(size)",
                    element: element,
                    app: app
                )
            }
        }
    }
}

// MARK: UISwitch State
extension XCUIElement {
    var isOn: Bool {
        get {
            guard let state = self.value as? String else {
                XCTFail("Unable to determine state of switch: \(self)")
                return false
            }
            
            return state == "1"
        }
        set {
            if self.isOn == newValue {
                return
            }
            self.tap()
        }
    }
}

// MARK: UIPicker
extension XCUIElement {
    func setPicker(to:String, _ test:XCTestCase, file:StaticString=#file, line:UInt=#line) {
        self.assertExists(file:file, line:line)
        let pkrWheel = self.pickerWheels.element
        pkrWheel.assertHittable(file:file, line:line)
        // Sadly there is not a good way to check if the picker contains a value before trying to select it
        // And there is also no way to propagate the error via file/line.
        pkrWheel.adjust(toPickerWheelValue:to)
    }
}

// MARK: Tapping on a CGPoint
// These are useful when the element you want to target not hittable
// due to not being covered, not exposed to Accessibility, etc.
extension XCUIElement {

    // Note: XCUICoordinates are specific to a particular XCUIApplication.
    private func coordinate(from cgPoint: CGPoint) -> XCUICoordinate {
        let normalized = self.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let coordinate = normalized.withOffset(CGVector(dx: cgPoint.x, dy: cgPoint.y))
        return coordinate
    }

    func tap(cgPoint: CGPoint) {
        let coordinate = self.coordinate(from: cgPoint)
        coordinate.tap()
    }

    func tap(placeholder: Placeholder) {
        tap(cgPoint: placeholder.frame.center)
    }
}

// MARK: Nav Bar & Back Button
extension XCUIElement {
    func tapBackButton(
        file: StaticString=#file,
        line: UInt=#line
    ) {
        WaitFor.tryThrows(file: file, line: line) {
            let query = self.navigationBars.buttons
            let backButton = query.firstMatch
            guard backButton.isHittable else {
                throw TestingError("Back button not hittable for query: \(query.debugDescription)")
            }
            backButton.tap()
        }
    }

    func expectNavBar(
        title: String? = nil,
        file: StaticString=#file,
        line: UInt=#line
    ) {
        WaitFor.tryThrows(file: file, line: line) {
            let query = self.navigationBars
            let navBar = query.firstMatch
            guard navBar.exists else {
                throw TestingError("Nav bar does not exist for query: \(query.debugDescription)")
            }

            guard let title = title else {
                return
            }

            let actual = navBar.identifier
            guard title == actual else {
                throw TestingError("Expected nav bar title to be [\(title)], got [\(actual)] for query: \(query)")
            }
        }
    }

    func expectNoNavBar(
        file: StaticString=#file,
        line: UInt=#line
    ) {
        WaitFor.tryThrows(file: file, line: line) {
            let query = self.navigationBars
            let navBar = query.firstMatch
            guard !navBar.exists else {
                throw TestingError("Nav bar exists!")
            }
        }
    }

    func expectNoBackButton(
        file: StaticString=#file,
        line: UInt=#line
    ) {
        WaitFor.tryThrows(file: file, line: line) {
            let backButton = self.navigationBars.buttons["Back"]
            if backButton.exists {
                throw TestingError("Back Button exists!")
            }
        }
    }
}

// MARK: Array
extension Array where Element == XCUIElement {
    var placeholders: [Placeholder] {
        self.map {
            Placeholder($0)
        }
    }
}
