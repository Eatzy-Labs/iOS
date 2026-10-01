//
//  OnboardingPreferenceView.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import SwiftUI

struct OnboardingPreferenceView: View {
    let store: StoreOf<OnboardingFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("3/3")
                    .applyEatzyFont(.body_18_m)
                    .foregroundStyle(.gray700)
                    .padding(.top, 24)

                Text("Personalize your experience")
                    .applyEatzyFont(.display_22_sb)
                    .foregroundStyle(.coreBlack)
                    .padding(.top, 12)

                if store.isTaxonomyLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if let message = store.taxonomyErrorMessage {
                    taxonomyError(message)
                } else {
                    optionSection(
                        title: "Religious Preference",
                        options: store.religionOptions,
                        selections: store.selectedReligions,
                        action: OnboardingFeature.Action.religionTapped
                    )
                    .padding(.top, 24)

                    optionSection(
                        title: "Dietary Preference",
                        options: store.dietOptions,
                        selections: store.selectedDiets,
                        action: OnboardingFeature.Action.dietTapped
                    )
                    .padding(.top, 40)
                }
            }
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            EatzyCTAButton(
                "Continue",
                state: isContinueEnabled ? .active : .inactive
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

    private var isContinueEnabled: Bool {
        !store.selectedReligions.isEmpty && !store.selectedDiets.isEmpty
    }

    private func optionSection(
        title: String,
        options: [OnboardingFeature.Option],
        selections: Set<String>,
        action: @escaping (String) -> OnboardingFeature.Action
    ) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .applyEatzyFont(.button_18_m)
                .foregroundStyle(.gray700)

            OnboardingFlowLayout(horizontalSpacing: 8, verticalSpacing: 16) {
                ForEach(options) { option in
                    EatzyButtonOption(
                        option.title,
                        state: selections.contains(option.id) ? .selected : .unselected
                    ) {
                        store.send(action(option.id))
                    }
                }
            }
            .padding(.horizontal, -4)
        }
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

struct OnboardingFlowLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        layout(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, point) in result.points.enumerated() {
            let size = result.sizes[index]
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
        }
    }

    private func layout(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> (size: CGSize, points: [CGPoint], sizes: [CGSize]) {
        let maximumWidth = proposal.width ?? .infinity
        var points: [CGPoint] = []
        var sizes: [CGSize] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            sizes.append(size)
            if x > 0, x + size.width > maximumWidth {
                x = 0
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }
            points.append(CGPoint(x: x, y: y))
            x += size.width + horizontalSpacing
            rowHeight = max(rowHeight, size.height)
        }

        return (
            CGSize(width: proposal.width ?? x, height: y + rowHeight),
            points,
            sizes
        )
    }
}
