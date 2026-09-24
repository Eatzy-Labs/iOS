//
//  RootView.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
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

        case .onboarding:
            OnboardingView(
                store: store.scope(state: \.onboarding, action: \.onboarding)
            )

        case .signUp:
            SignUpView(
                store: store.scope(state: \.signUp, action: \.signUp)
            )

        case .mainTab:
            MainTabView(
                store: store.scope(state: \.mainTab, action: \.mainTab)
            )
        }
    }
}
