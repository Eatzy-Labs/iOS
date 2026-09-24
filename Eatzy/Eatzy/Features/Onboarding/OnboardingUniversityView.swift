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

    private let universities = ["KNU"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            stepLabel

            Text("Select your university")
                .applyEatzyFont(.display_22_sb)
                .foregroundStyle(.coreBlack)
                .padding(.top, 12)

            EatzyDropdown(
                title: store.selectedUniversity.first ?? "Please Select",
                options: universities,
                selections: Binding(
                    get: { store.selectedUniversity },
                    set: { store.send(.universitySelectionChanged($0)) }
                )
            )
            .padding(.top, 28)

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
