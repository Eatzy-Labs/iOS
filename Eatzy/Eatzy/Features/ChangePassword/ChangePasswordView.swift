//
//  ChangePasswordView.swift
//  Eatzy
//
//  Created by sun on 10/11/26.
//

import ComposableArchitecture
import SwiftUI

struct ChangePasswordView: View {
    let store: StoreOf<ChangePasswordFeature>

    var body: some View {
        VStack(spacing: 0) {
            EatzyNavigationBar(
                leading: .back {
                    store.send(.backButtonTapped)
                }
            )

            Group {
                switch store.step {
                case .currentPassword:
                    currentPasswordContent
                case .newPassword:
                    newPasswordContent
                }
            }
        }
        .background(.coreWhite)
        .hideKeyboardOnBackgroundTap()
    }
}

private extension ChangePasswordView {
    var currentPasswordContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            stepLabel("1/2")

            Text("Enter your current password to continue")
                .applyEatzyFont(.body_18_m)
                .foregroundStyle(.gray900)
                .padding(.top, 12)

            EatzyTextfield(
                text: Binding(
                    get: { store.currentPassword },
                    set: { store.send(.currentPasswordChanged($0)) }
                ),
                state: Binding(
                    get: { store.currentPasswordFieldState },
                    set: { store.send(.currentPasswordFieldStateChanged($0)) }
                ),
                placeholder: "Type here",
                maximumLength: 64,
                isSecure: true,
                showsCounter: false,
                onSubmit: {
                    store.send(.currentPasswordSubmitted)
                }
            )
            .padding(.top, 28)

            Spacer(minLength: 24)
        }
        .padding(.horizontal, 20)
    }

    var newPasswordContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                stepLabel("2/2")

                Text("Enter your new password")
                    .applyEatzyFont(.body_18_m)
                    .foregroundStyle(.gray900)
                    .padding(.top, 12)

                EatzyTextfield(
                    text: Binding(
                        get: { store.newPassword },
                        set: { store.send(.newPasswordChanged($0)) }
                    ),
                    state: Binding(
                        get: { store.newPasswordFieldState },
                        set: { store.send(.newPasswordFieldStateChanged($0)) }
                    ),
                    placeholder: "Type here",
                    maximumLength: 64,
                    isSecure: true,
                    showsCounter: false,
                    onSubmit: {
                        store.send(.newPasswordSubmitted)
                    }
                )
                .padding(.top, 28)

                if store.showsPasswordConfirmation {
                    Text("Confirm new password")
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
                        showsCounter: false,
                        showsErrorIcon: false,
                        onFocusChanged: {
                            store.send(.confirmedPasswordFocusChanged($0))
                        }
                    )
                    .padding(.top, 12)
                }
            }
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            EatzyCTAButton(
                "Confirm",
                state: store.canConfirm ? .active : .inactive
            ) {
                store.send(.confirmButtonTapped)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    func stepLabel(_ text: String) -> some View {
        Text(text)
            .applyEatzyFont(.body_18_m)
            .foregroundStyle(.gray700)
            .padding(.top, 24)
    }
}
