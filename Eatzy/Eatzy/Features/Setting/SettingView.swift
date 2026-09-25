//
//  SettingView.swift
//  Eatzy
//

import ComposableArchitecture
import SwiftUI

struct SettingView: View {
    let store: StoreOf<SettingFeature>

    var body: some View {
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
                                userID: "happypibi1122",
                                university: "POSTECH"
                            )
                        } else {
                            SettingLoginCard {
                                store.send(.loginButtonTapped)
                            }
                        }
                    }

                    settingSection("PREFERENCES") {
                        SettingMenuCard(items: [
                            .init(title: "Language Preferences"),
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
                                .init(title: "Log Out"),
                                .init(title: "Delete Account", titleColor: .red500)
                            ])
                        }
                    }
                }
                .padding(.horizontal, 16)
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
}
