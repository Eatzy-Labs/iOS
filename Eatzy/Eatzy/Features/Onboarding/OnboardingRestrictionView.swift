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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Personalize your experience")
                    .applyEatzyFont(.display_22_sb)
                    .foregroundStyle(.coreBlack)
                    .padding(.top, 24)

                if store.isTaxonomyLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if let message = store.taxonomyErrorMessage {
                    taxonomyError(message)
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Food Restrictions")
                            .applyEatzyFont(.button_18_m)
                            .foregroundStyle(.gray700)

                        OnboardingFlowLayout(horizontalSpacing: 8, verticalSpacing: 16) {
                            ForEach(store.restrictionOptions) { restriction in
                                EatzyButtonOption(
                                    restriction.title,
                                    state: store.selectedFoodRestrictions.contains(restriction.id)
                                        ? .selected
                                        : .unselected
                                ) {
                                    store.send(.foodRestrictionTapped(restriction.id))
                                }
                            }
                        }
                        .padding(.horizontal, -4)
                    }
                    .padding(.top, 24)
                }
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
            .padding(.top, 20)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
            .background(.coreWhite)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func taxonomyError(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .applyEatzyFont(.body_14_r)
                .foregroundStyle(.gray500)

            Button("Retry") {
                store.send(.taxonomyRetryTapped)
            }
            .applyEatzyFont(.button_14_m)
            .foregroundStyle(.orange500)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}
