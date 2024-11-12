import Combine

/// A protocol representing a ViewModel in the MVVM architecture.
/// ViewModels conforming to this protocol should transform input to output, and manage the cancellation of ongoing tasks.
public protocol ViewModel: ObservableObject {
    /// The type of input that the ViewModel will receive.
    associatedtype Input
    /// The type of output that the ViewModel will produce.
    associatedtype Output = Never
    
    /// Transforms the input to the output.
    /// - Parameters:
    ///   - input: The input to be transformed.
    ///   - cancelBag: A container to manage the cancellation of ongoing tasks.
    /// - Returns: The transformed output.
    func transform(_ input: Input, cancelBag: CancelBag) -> Output
}

extension ViewModel where Output == Never {
    /// A default implementation of the transform function for ViewModels that do not produce any output.
    /// This is useful for cases where the ViewModel only handles input without producing any output.
    /// - Parameters:
    ///   - input: The input to be processed.
    ///   - cancelBag: A container to manage the cancellation of ongoing tasks.
    public func transform(_ input: Input, cancelBag: CancelBag) {
        // Default implementation does nothing since there is no output.
    }
}

