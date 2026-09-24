//
//  SignUpPasswordView.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import SwiftUI

struct SignUpPasswordView: View {
    let store: StoreOf<SignUpFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Create a password")
                    .applyEatzyFont(.display_22_sb)
                    .foregroundStyle(.coreBlack)
                    .padding(.top, 32)

                EatzyTextfield(
                    text: Binding(
                        get: { store.password },
                        set: { store.send(.passwordChanged($0)) }
                    ),
                    state: Binding(
                        get: { store.passwordFieldState },
                        set: { store.send(.passwordFieldStateChanged($0)) }
                    ),
                    placeholder: "Type here",
                    maximumLength: 64,
                    isSecure: true,
                    showsCounter: false
                )
                .padding(.top, 32)

                if store.showsPasswordConfirmation {
                    Text("Confirm a password")
                        .applyEatzyFont(.body_18_m)
                        .foregroundStyle(.gray700)
                        .padding(.top, 32)

                    EatzyTextfield(
                        text: Binding(
                            get: { store.confirmedPassword },
                            set: { store.send(.confirmedPasswordChanged($0)) }
                        ),
                        state: Binding(
                            get: { store.confirmedPasswordFieldState },
                            set: { store.send(.confirmedPasswordFieldStateChanged($0)) }
                        ),
                        placeholder: "Type here",
                        maximumLength: 64,
                        isSecure: true,
                        showsCounter: false
                    )
                    .padding(.top, 12)
                }
            }
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            EatzyCTAButton(
                "Get started",
                state: store.canCompleteSignUp ? .active : .inactive
            ) {
                store.send(.continueButtonTapped)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
