import Foundation

extension Equatable {
    func isIn (_ rhs: any Collection<Self>) -> Bool {
        rhs.contains(self)
    }
}
