//
//  RootView.swift
//  Eatzy
//

import ComposableArchitecture
import SwiftUI

struct RootView: View {
    let store: StoreOf<RootFeature>

    var body: some View {
        switch store.route {
        case .splash:
            SplashView()
                .task {
                    await store.send(.splashTask).finish()
                }

        case .login:
            LoginView(
                store: store.scope(state: \.login, action: \.login)
            )
        }
    }
}
