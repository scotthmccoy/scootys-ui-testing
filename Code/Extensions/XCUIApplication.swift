import XCTest

// TODO: Add common applications (springboard, settings, etc) as lazy static vars

public extension XCUIApplication {
    func screenFrame() -> CGRect {
        self.windows.element(boundBy: 0).frame
    }
    
    func tap(point:CGPoint) {
        let normalized = self.coordinate(withNormalizedOffset: CGVector(dx:0, dy:0))
        let coordinate = normalized.withOffset(CGVector(dx:point.x, dy:point.y))
        coordinate.tap()
    }
}
