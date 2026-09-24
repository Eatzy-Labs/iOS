//
//  OnboardingCountryView.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import SwiftUI

struct OnboardingCountryView: View {
    let store: StoreOf<OnboardingFeature>

    private let countries = ["country1", "country2", "country3", "country4", "country5"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("2/3")
                .applyEatzyFont(.body_18_m)
                .foregroundStyle(.gray700)
                .padding(.top, 24)

            Text("Where are you from?")
                .applyEatzyFont(.display_22_sb)
                .foregroundStyle(.coreBlack)
                .padding(.top, 12)

            EatzyDropdown(
                title: store.selectedCountry.first ?? "Please Select",
                options: countries,
                selections: Binding(
                    get: { store.selectedCountry },
                    set: { store.send(.countrySelectionChanged($0)) }
                )
            )
            .padding(.top, 28)

            Spacer(minLength: 24)
        }
        .padding(.horizontal, 20)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            EatzyCTAButton(
                "Continue",
                state: store.selectedCountry.isEmpty ? .inactive : .active
            ) {
                store.send(.continueButtonTapped)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
