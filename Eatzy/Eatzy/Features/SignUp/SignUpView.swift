//
//  SignUpView.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import SwiftUI

struct SignUpView: View {
    let store: StoreOf<SignUpFeature>

    var body: some View {
        VStack(spacing: 0) {
            EatzyNavigationBar(
                leading: .back {
                    store.send(.backButtonTapped)
                }
            )

            switch store.step {
            case .email:
                SignUpEmailView(store: store)
            case .password:
                SignUpPasswordView(store: store)
            }
        }
        .background(.coreWhite)
    }
}
