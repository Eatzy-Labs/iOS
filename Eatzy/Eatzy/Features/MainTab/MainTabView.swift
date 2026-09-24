//
//  MainTabView.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import SwiftUI

struct MainTabView: View {
    let store: StoreOf<MainTabFeature>

    var body: some View {
        if store.isSettingPresented {
            SettingView(
                isAuthenticated: store.isAuthenticated,
                onBackTapped: { store.send(.settingBackButtonTapped) },
                onLoginTapped: { store.send(.settingLoginButtonTapped) }
            )
        } else {
            TabView(
                selection: Binding(
                    get: { store.selectedTab },
                    set: { store.send(.tabSelected($0)) }
                )
            ) {
                Tab("Menu", systemImage: "fork.knife", value: MainTabFeature.State.Tab.menu) {
                    MenuView(store: store)
                }

                Tab("Map", systemImage: "map.fill", value: MainTabFeature.State.Tab.map) {
                    MapView(store: store)
                }
            }
            .tint(.orange500)
        }
    }
}
