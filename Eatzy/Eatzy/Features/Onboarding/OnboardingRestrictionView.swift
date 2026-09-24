//
//  OnboardingRestrictionView.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import SwiftUI

struct OnboardingRestrictionView: View {
    let store: StoreOf<OnboardingFeature>

    private let restrictions = [
        "No Restriction",
        "No Egg (Poultry only)", "No Milk",
        "No Buckwheat", "No Pine Nut",
        "No Walnut", "No Crab",
        "No Shrimp", "No Squid",
        "No Mackerel",
        "No Shellfish (Oyster, Ablaone, Mussel)",
        "No Peach", "No Tomato",
        "No Chicken", "No Pork",
        "No Beef", "No Sulfites / SO₂"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Personalize your experience")
                    .applyEatzyFont(.display_22_sb)
                    .foregroundStyle(.coreBlack)
                    .padding(.top, 24)

                VStack(alignment: .leading, spacing: 20) {
                    Text("Food Restrictions")
                        .applyEatzyFont(.button_18_m)
                        .foregroundStyle(.gray700)

                    OnboardingFlowLayout(spacing: 8) {
                        ForEach(restrictions, id: \.self) { restriction in
                            EatzyButtonOption(
                                restriction,
                                state: store.selectedFoodRestrictions.contains(restriction)
                                    ? .selected
                                    : .unselected
                            ) {
                                store.send(.foodRestrictionTapped(restriction))
                            }
                        }
                    }
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            EatzyCTAButton(
                store.entryPoint.completionButtonTitle,
                state: store.selectedFoodRestrictions.isEmpty ? .inactive : .active
            ) {
                store.send(.continueButtonTapped)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
