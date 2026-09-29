//
//  SettingView.swift
//  Eatzy
//

import ComposableArchitecture
import SwiftUI

struct SettingView: View {
    let store: StoreOf<SettingFeature>

    var body: some View {
        Group {
            if store.isProfilePresented {
                ProfileView(
                    store: store.scope(state: \.profile, action: \.profile)
                )
            } else {
                settingContent
            }
        }
        .task {
            await store.send(.viewAppeared).finish()
        }
        .alert("Log out?", isPresented: logoutAlertPresentation) {
            Button("Cancel", role: .cancel) {}

            Button("Log out", role: .destructive) {
                store.send(.logoutConfirmed)
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }

    var settingContent: some View {
        VStack(spacing: 0) {
            EatzyNavigationBar(
                leading: .back {
                    store.send(.backButtonTapped)
                }
            )

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 28) {
                    settingSection("PROFILE") {
                        if store.isAuthenticated {
                            SettingProfileCard(
                                userID: store.profile.profile.userID,
                                university: store.profile.profile.university
                            ) {
                                store.send(.profileCardTapped)
                            }
                        } else {
                            SettingLoginCard {
                                store.send(.loginButtonTapped)
                            }
                        }
                    }

                    settingSection("PREFERENCES") {
                        SettingMenuCard(items: [
                            .init(title: "Dietary Preferences")
                        ])
                    }

                    settingSection("ABOUT") {
                        SettingMenuCard(items: [
                            .init(title: "Version", value: "1.0.0", showsChevron: false),
                            .init(title: "Terms of Service"),
                            .init(title: "Privacy Policy")
                        ])
                    }

                    if store.isAuthenticated {
                        settingSection("ACCOUNT") {
                            SettingMenuCard(items: [
                                .init(title: "Change Password"),
                                .init(title: "Log Out") {
                                    store.send(.logoutButtonTapped)
                                },
                                .init(title: "Delete Account", titleColor: .red500)
                            ])
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.gray100)
    }

    func settingSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .applyEatzyFont(.caption_12_m)
                .foregroundStyle(.gray500)
                .padding(.leading, 4)

            content()
        }
    }

    var logoutAlertPresentation: Binding<Bool> {
        Binding(
            get: { store.isLogoutAlertPresented },
            set: { store.send(.logoutAlertPresentationChanged($0)) }
        )
    }
}
