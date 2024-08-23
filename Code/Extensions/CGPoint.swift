import Foundation
import UIKit

extension CGRect {
    public var center: CGPoint {
        let x = self.origin.x + self.size.width / 2
        let y = self.origin.y + self.size.height / 2
        return CGPoint(x:x, y:y)
    }
}
