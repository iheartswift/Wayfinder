//
//  WayfinderContainer.swift
//  Wayfinder
//
//  Created by Adam Dahan on 2025-02-10.
//

import SwiftUI

/// A container view that encapsulates the navigation stack and sheet presentation logic.
/// The consumer only needs to supply an initial route and a view resolver.
public struct WayfinderContainer<Route: Routable>: View {
    @StateObject private var wayfinder = Wayfinder<Route>()
    private let initialRoute: Route
    private let viewResolver: (Route) -> AnyView

    /// Creates a Wayfinder container.
    ///
    /// - Parameters:
    ///   - initialRoute: The route that represents the root view.
    ///   - viewResolver: A closure that maps a route to a SwiftUI view.
    public init(initialRoute: Route, viewResolver: @escaping (Route) -> AnyView) {
         self.initialRoute = initialRoute
         self.viewResolver = viewResolver
    }

    public var body: some View {
         NavigationStack(path: $wayfinder.path) {
             // The initial view is provided by the viewResolver.
             viewResolver(initialRoute)
                 .navigationDestination(for: Route.self) { route in
                     viewResolver(route)
                 }
                 .sheet(item: $wayfinder.sheet) { route in
                     Group {
                         if !wayfinder.sheetDetents.isEmpty {
                             viewResolver(route)
                                 .presentationDetents(wayfinder.sheetDetents)
                         } else {
                             viewResolver(route)
                         }
                     }
                 }
         }
         .onAppear {
              // Set the internal viewResolver and start at the initial route.
              wayfinder.viewResolver = viewResolver
              wayfinder.navigate(to: initialRoute, style: .push)
         }
         .environmentObject(wayfinder)
    }
}
