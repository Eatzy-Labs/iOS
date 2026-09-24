//
//  OnboardingView.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import SwiftUI

struct OnboardingView: View {
    let store: StoreOf<OnboardingFeature>

    var body: some View {
        VStack(spacing: 0) {
            EatzyNavigationBar(
                leading: .back {
                    store.send(.backButtonTapped)
                }
            )

            switch store.step {
            case .university:
                OnboardingUniversityView(store: store)
            case .country:
                OnboardingCountryView(store: store)
            case .preference:
                OnboardingPreferenceView(store: store)
            case .restriction:
                OnboardingRestrictionView(store: store)
            }
        }
        .background(.coreWhite)
    }
}
