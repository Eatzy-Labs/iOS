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

            if store.isCountriesLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
            } else if let message = store.countriesErrorMessage {
                VStack(spacing: 12) {
                    Text(message)
                        .applyEatzyFont(.body_14_r)
                        .foregroundStyle(.gray500)

                    Button("Retry") {
                        store.send(.countriesRetryTapped)
                    }
                    .applyEatzyFont(.button_14_m)
                    .foregroundStyle(.orange500)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 28)
            } else {
                EatzyDropdown(
                    title: store.selectedCountryTitle,
                    options: store.countryOptions,
                    selections: Binding(
                        get: { store.selectedCountry },
                        set: { store.send(.countrySelectionChanged($0)) }
                    ),
                    optionTitle: { code in
                        store.countries.first(where: { $0.code == code })?.name ?? code
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
