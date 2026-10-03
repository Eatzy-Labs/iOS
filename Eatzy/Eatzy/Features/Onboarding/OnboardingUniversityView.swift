//
//  OnboardingUniversityView.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import SwiftUI

struct OnboardingUniversityView: View {
    let store: StoreOf<OnboardingFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            stepLabel

            Text("Select your university")
                .applyEatzyFont(.display_22_sb)
                .foregroundStyle(.coreBlack)
                .padding(.top, 12)

            if store.isUniversitiesLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
            } else if let message = store.universitiesErrorMessage {
                VStack(spacing: 12) {
                    Text(message)
                        .applyEatzyFont(.body_14_r)
                        .foregroundStyle(.gray500)

                    Button("Retry") {
                        store.send(.universitiesRetryTapped)
                    }
                    .applyEatzyFont(.button_14_m)
                    .foregroundStyle(.orange500)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 28)
            } else {
                EatzyDropdown(
                    title: store.selectedUniversityTitle,
                    options: store.universityOptions,
                    selections: Binding(
                        get: { store.selectedUniversity },
                        set: { store.send(.universitySelectionChanged($0)) }
                    ),
                    optionTitle: { code in
                        store.universities.first(where: { $0.code == code })?.nameEn ?? code
                    }
                )
                .padding(.top, 28)
            }

            Spacer(minLength: 24)
        }
        .padding(.horizontal, 20)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            EatzyCTAButton(
                "Continue",
                state: store.selectedUniversity.isEmpty ? .inactive : .active
            ) {
                store.send(.continueButtonTapped)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var stepLabel: some View {
        Text("1/3")
            .applyEatzyFont(.body_18_m)
            .foregroundStyle(.gray700)
            .padding(.top, 24)
    }
}
