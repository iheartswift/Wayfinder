
import SwiftUI

/// Defines the presentation style for navigation.
public enum PresentationStyle {
    case push
    case sheet
    /// Use this case when you want to specify detents.
    case sheetWithDetents(detents: Set<PresentationDetent>)
}

/// A generic navigator (or router) that manages navigation state.
/// The generic parameter `Route` must conform to `Routable`.
public final class Wayfinder<Route: Routable>: ObservableObject {
    
    /// The navigation path for push-style navigation.
    @Published public var path = NavigationPath()
    
    /// A route to be presented as a sheet.
    @Published public var sheet: Route?
    
    /// Holds the detents to use when presenting a sheet.
    /// If empty, no specific detents are applied.
    @Published public var sheetDetents: Set<PresentationDetent> = []
    
    /// A closure that maps a given route to a SwiftUI view.
    public var viewResolver: ((Route) -> AnyView)?
    
    public init() { }
    
    /// Navigates to the given route using the specified presentation style.
    public func navigate(to route: Route, style: PresentationStyle) {
        switch style {
        case .push:
            path.append(route)
        case .sheet:
            sheet = nil
            sheet = route
            sheetDetents = [] // No detents provided.
        case .sheetWithDetents(let detents):
            sheet = route
            sheetDetents = detents
        }
    }
    
    /// Pops the last view from the navigation stack.
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    /// Pops back to the root view.
    public func popToRoot() {
        path.removeLast(path.count)
    }
    
    /// Dismisses the currently presented sheet.
    public func dismissSheet() {
        sheet = nil
    }
    
    /// Resolves a SwiftUI view for the given route using the viewResolver.
    /// Returns an EmptyView if no resolver is provided.
    public func resolveView(for route: Route) -> AnyView {
        viewResolver?(route) ?? AnyView(EmptyView())
    }
}
