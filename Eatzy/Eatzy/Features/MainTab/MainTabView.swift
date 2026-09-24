//
//  MainTabView.swift
//  Eatzy
//

import ComposableArchitecture
import SwiftUI

struct MainTabView: View {
    let store: StoreOf<MainTabFeature>

    var body: some View {
        TabView(
            selection: Binding(
                get: { store.selectedTab },
                set: { store.send(.tabSelected($0)) }
            )
        ) {
            Tab("Menu", systemImage: "fork.knife", value: MainTabFeature.State.Tab.menu) {
                MenuView()
            }

            Tab("Map", systemImage: "map.fill", value: MainTabFeature.State.Tab.map) {
                MapView()
            }
        }
        .tint(.purple500)
    }
}
