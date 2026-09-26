//
//  MenuSheetView.swift
//  Eatzy
//

import ComposableArchitecture
import SwiftUI

struct MenuSheetView: View {
    let store: StoreOf<MenuSheetFeature>

    var body: some View {
        Color.coreWhite
            .ignoresSafeArea()
    }
}

#Preview {
    MenuSheetView(store: Store(initialState: MenuSheetFeature.State()) {
        MenuSheetFeature()
    })
}

