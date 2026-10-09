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
                VStack(spacing: 8) {
                    EatzySearchTextField(
                        text: Binding(
                            get: { store.countrySearchText },
                            set: { store.send(.countrySearchTextChanged($0)) }
                        ),
                        isSelected: !store.selectedCountry.isEmpty
                    )

                    countryResults
                }
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

    private var countryResults: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.filteredCountries, id: \.code) { country in
                    let isSelected = store.selectedCountry.contains(country.code)

                    Button {
                        store.send(.countryTapped(country.code))
                        hideKeyboard()
                    } label: {
                        HStack(alignment: .center, spacing: 8) {
                            Text(country.name)
                                .applyEatzyFont(isSelected ? .body_18_m : .body_18_r)
                                .foregroundStyle(.gray900)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if isSelected {
                                Image(.icSuccess)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, minHeight: 52, maxHeight: 52)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Rectangle()
                        .fill(.gray300)
                        .frame(height: 1)
                }
            }
        }
        .scrollIndicators(.hidden)
        .frame(maxHeight: 240)
        .background(.coreWhite)
        .overlay(alignment: .topTrailing) {
            Capsule()
                .fill(.gray300)
                .frame(width: 5, height: 52)
                .padding(.top, 16)
                .padding(.trailing, 4)
                .allowsHitTesting(false)
        }
    }
}
