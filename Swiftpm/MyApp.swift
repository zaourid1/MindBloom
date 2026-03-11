//
//  MyApp.swift
//  MindBloom
//
//  Created by Zineb Aourid on 2026-02-28.
//
import SwiftUI

@main
struct MyApp: App {
    @StateObject private var store = BrainStore()   // single shared store
    @State private var path: [Route] = []

    enum Route: Hashable {
        case train
        case test
        case explore
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                ContentView(
                    store: store,
                    onTrain: { path.append(.train) },
                    onTest: { path.append(.test) },
                    onExplore: { path.append(.explore) }
                )
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .train:
                        TrainView(store: store)
                    case .test:
                        TestView(store: store)
                    case .explore:
                        ExploreView(store: store)
                    }
                }
            }
        }
    }
}
