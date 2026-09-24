//
//  LoginView.swift
//  Eatzy
//

import ComposableArchitecture
import SwiftUI

struct LoginView: View {
    let store: StoreOf<LoginFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Welcome!")
                    .applyEatzyFont(.display_22_sb)
                    .foregroundStyle(.gray900)

                Text("Login to continue your campus life")
                    .applyEatzyFont(.body_18_m)
                    .foregroundStyle(.gray700)
                    .padding(.top, 12)

                VStack(spacing: 12) {
                    EatzyTextfield(
                        text: Binding(
                            get: { store.email },
                            set: { store.send(.emailChanged($0)) }
                        ),
                        state: Binding(
                            get: { store.emailFieldState },
                            set: { store.send(.emailFieldStateChanged($0)) }
                        ),
                        placeholder: "Email",
                        maximumLength: 64,
                        showsCounter: false,
                        keyboardType: .emailAddress
                    )

                    EatzyTextfield(
                        text: Binding(
                            get: { store.password },
                            set: { store.send(.passwordChanged($0)) }
                        ),
                        state: Binding(
                            get: { store.passwordFieldState },
                            set: { store.send(.passwordFieldStateChanged($0)) }
                        ),
                        placeholder: "Password",
                        maximumLength: 64,
                        isSecure: true,
                        showsCounter: false
                    )
                }
                .padding(.top, 33)

                EatzyCTAButton(
                    "Login",
                    state: store.isLoginEnabled ? .active : .inactive
                ) {
                    store.send(.loginButtonTapped)
                }
                .padding(.top, 20)

                VStack(spacing: 13) {
                    HStack(spacing: 8) {
                        Text("Don’t have an account?")
                            .applyEatzyFont(.caption_12_r)
                            .foregroundStyle(.gray700)

                        Button("Sign Up") {
                            store.send(.signUpButtonTapped)
                        }
                        .applyEatzyFont(.button_14_m)
                        .foregroundStyle(.orange500)
                        .buttonStyle(.plain)
                    }

                    HStack(spacing: 8) {
                        Text("Or continue as")
                            .applyEatzyFont(.caption_12_r)
                            .foregroundStyle(.gray700)

                        Button("Guest") {
                            store.send(.guestButtonTapped)
                        }
                        .applyEatzyFont(.button_14_m)
                        .foregroundStyle(.gray900)
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 32)
            }
            .padding(.horizontal, 20)
            .padding(.top, 96)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(.coreWhite)
    }
}
