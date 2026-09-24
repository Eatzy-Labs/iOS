//
//  EatzyApp.swift
//  Eatzy
//
//  Created by sun on 9/23/26.
//

import ComposableArchitecture
import SwiftUI

@main
struct EatzyApp: App {
    private let store = Store(initialState: RootFeature.State()) {
        RootFeature()
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
