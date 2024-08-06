/// An enumeration representing the different loading states of a screen.
/// This enum helps in distinguishing between initial loading, reloading, and loading more states with associated input data.
public enum LoadingState<Input> {
    /// Represents the initial loading state with associated input data.
    case initial(Input)
    
    /// Represents the reloading state with associated input data.
    case reload(Input)
    
    /// Represents the loading more state (for pagination) with associated input data.
    case loadMore(Input)
}
