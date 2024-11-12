import UIKit

/// A protocol that defines a bindable ViewController.
/// ViewControllers conforming to this protocol should bind to a ViewModel of a specified type.
public protocol Bindable: AnyObject {
    /// The type of ViewModel associated with the ViewController.
    associatedtype ViewModel
    
    /// The ViewModel instance that will be bound to the ViewController.
    var viewModel: ViewModel! { get set }
    
    /// A method to bind the ViewModel to the ViewController.
    /// This method should be implemented by conforming ViewControllers to establish bindings between the ViewModel and the ViewController.
    func bindViewModel()
}

extension Bindable where Self: UIViewController {
    /// Binds the provided ViewModel to the ViewController.
    ///
    /// - Parameter viewModel: The ViewModel instance to bind to the ViewController.
    public func bindViewModel(to viewModel: Self.ViewModel) {
        self.viewModel = viewModel
        loadViewIfNeeded() // Ensure the view is loaded before binding
        bindViewModel() // Call the method to bind the ViewModel to the ViewController
    }
}
