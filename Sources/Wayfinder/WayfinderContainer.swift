//
//  WayfinderContainer.swift
//  Wayfinder
//
//  Created by Adam Dahan on 2025-02-10.
//

import SwiftUI

public struct WayfinderContainer<Route: Routable>: View {
    @StateObject private var wayfinder = Wayfinder<Route>()
    private let initialRoute: Route
    private let viewResolver: (Route) -> AnyView

    public init(initialRoute: Route, viewResolver: @escaping (Route) -> AnyView) {
        self.initialRoute = initialRoute
        self.viewResolver = viewResolver
    }

    public var body: some View {
        NavigationStack(path: $wayfinder.path) {
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
            wayfinder.viewResolver = viewResolver
            if wayfinder.path.isEmpty {
                wayfinder.navigate(to: initialRoute, style: .push) // ✅ Only navigate if path is empty
            }
        }
        .environmentObject(wayfinder)
    }
}
