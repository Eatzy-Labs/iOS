//
//  SignUpEmailView.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import SwiftUI

struct SignUpEmailView: View {
    let store: StoreOf<SignUpFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Enter your email")
                .applyEatzyFont(.display_22_sb)
                .foregroundStyle(.coreBlack)
                .padding(.top, 32)

            EatzyTextfield(
                text: Binding(
                    get: { store.email },
                    set: { store.send(.emailChanged($0)) }
                ),
                state: Binding(
                    get: { store.emailFieldState },
                    set: { store.send(.emailFieldStateChanged($0)) }
                ),
                placeholder: "Type here",
                maximumLength: 64,
                showsCounter: false,
                showsErrorIcon: false,
                keyboardType: .emailAddress
            )
            .padding(.top, 32)

            Spacer(minLength: 24)
        }
        .padding(.horizontal, 20)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            EatzyCTAButton(
                "Continue",
                state: store.canContinueFromEmail ? .active : .inactive
            ) {
                store.send(.continueButtonTapped)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
