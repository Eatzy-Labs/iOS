//
//  DeleteAccountView.swift
//  Eatzy
//
//  Created by sun on 10/12/26.
//

import ComposableArchitecture
import SwiftUI

struct DeleteAccountView: View {
    let store: StoreOf<DeleteAccountFeature>

    var body: some View {
        VStack(spacing: 0) {
            EatzyNavigationBar(
                leading: .back {
                    store.send(.backButtonTapped)
                }
            )

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Delete Account")
                            .applyEatzyFont(.display_22_sb)
                            .foregroundStyle(.coreBlack)
                            .padding(.top, 24)

                        Text(
                            "Your profile information, preferences, and other data associated with your account will be permanently deleted.\nThis information cannot be restored, even if you create a new account later."
                        )
                        .applyEatzyFont(.caption_10_r)
                        .foregroundStyle(.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)

                        Text("Why are you leaving?")
                            .applyEatzyFont(.title_18_sb)
                            .foregroundStyle(.coreBlack)
                            .padding(.top, 28)

                        EatzySelectionList(
                            options: DeleteAccountFeature.State.reasons,
                            selection: Binding(
                                get: { store.selectedReason },
                                set: { store.send(.reasonSelected($0)) }
                            )
                        )
                        .padding(.top, 20)

                        if store.selectedReason == DeleteAccountFeature.State.otherReason {
                            EatzyTextEditor(
                                text: Binding(
                                    get: { store.otherReasonText },
                                    set: { store.send(.otherReasonChanged($0)) }
                                ),
                                maximumLength: 200,
                                errorMessage: store.otherReasonErrorMessage,
                                onFocusChanged: { isFocused in
                                    guard isFocused else { return }
                                    Task { @MainActor in
                                        await Task.yield()
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            proxy.scrollTo("otherReasonEditor", anchor: .top)
                                        }
                                    }
                                }
                            )
                            .id("otherReasonEditor")
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.coreWhite)
        .hideKeyboardOnBackgroundTap()
        .safeAreaInset(edge: .bottom, spacing: 0) {
            EatzyCTAButton(
                "Delete Account",
                state: store.canDelete ? .active : .inactive
            ) {
                store.send(.deleteAccountButtonTapped)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .background(.coreWhite)
        }
    }
}
