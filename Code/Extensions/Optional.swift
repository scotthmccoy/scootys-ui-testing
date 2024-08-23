import Foundation

public extension Optional {
    func defaultValue(_ defaultValue: Wrapped) -> Wrapped {
        guard let self else {
            return defaultValue
        }
        
        return self
    }
}
