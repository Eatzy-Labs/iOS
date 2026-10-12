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
    @Environment(\.openURL) private var openURL

    var body: some View {
        Group {
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
        .alert(
            store.updateAlert == .required ? "Update Required" : "Update Available",
            isPresented: updateAlertPresentation
        ) {
            if store.updateAlert == .recommended {
                Button("Not Now", role: .cancel) {
                    store.send(.updateAlertDismissed)
                }
            }

            Button("Update Now") {
                if let url = store.appStoreURL {
                    openURL(url)
                }
            }
        } message: {
            Text(
                store.updateAlert == .required
                    ? "Please update Eatzy to continue."
                    : "A new version of Eatzy is ready."
            )
        }
    }
}

private extension RootView {
    var updateAlertPresentation: Binding<Bool> {
        Binding(
            get: { store.updateAlert != nil },
            set: { isPresented in
                if !isPresented {
                    store.send(.updateAlertDismissed)
                }
            }
        )
    }
}
