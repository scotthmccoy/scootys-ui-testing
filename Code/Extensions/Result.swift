import Foundation

// Keystroke saver.
// Allows a function returning Result<Void, Error> to `return .success()`
extension Result where Success == Void {
    public static func success() -> Self { .success(()) }
}

extension Result {
    var shortDescription: String {
        return isSuccessful ? "successful" : "failed"
    }
    
    public var isSuccessful: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    public var error: Failure? {
        guard case let .failure(error) = self else {
            return nil
        }
        return error
    }

    public func getSuccess (
        failureHandler: (Failure) -> ()
    ) -> Success? {
        switch self {
        case .success(let success):
            return success
        case .failure(let failure):
            failureHandler(failure)
            return nil
        }
    }
}

// Note: This must be `== any Error` because errors caught in Swift catch blocks are of type Error (Swift's abstract Error
// instead of a concrete type of Error). Inelegant, yes, but it does remind us why we prefer Result over try/catch:
// we can get concretely typed errors.
extension Result where Failure == any Error {
    /*
        Async version of init(catching: () throws -> Success)
        Usage:
     
        Task {
            await Result.asyncCatching() {
                try await getInt()
            }.mapError { error in
                ConcreteError.wrap(error)
            }
        }
    */
    @available(iOS 13, *)
    static func asyncCatching(
        body: () async throws -> Success
    ) async -> Self {
        do {
            return Self.success(try await body())
        } catch {
            return .failure(error)
        }
    }
}

