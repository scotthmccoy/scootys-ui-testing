// TODO: Is this neccessary anymore? XCUIElementProxy might be better

import UIKit
import XCTest

public struct Placeholder {
    public var label:String
    public var frame:CGRect
}

public extension Placeholder {
    init (_ xcuiElement:XCUIElement) {
        self.init(label:xcuiElement.label, frame:xcuiElement.frame)
    }
}



