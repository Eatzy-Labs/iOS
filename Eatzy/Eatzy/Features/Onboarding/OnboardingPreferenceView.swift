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

    private let religions = [
        "No Preference", "Muslim (Halal)", "Jewish (Kosher)",
        "Christian", "Buddhist", "Hindu", "Sikh"
    ]
    private let diets = [
        "No Preference", "Vegan", "Vegetarian", "Keto",
        "Gluten-Free", "Dairy-Free"
    ]

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

                optionSection(
                    title: "Religious Preference",
                    options: religions,
                    selections: store.selectedReligions,
                    action: OnboardingFeature.Action.religionTapped
                )
                .padding(.top, 24)

                optionSection(
                    title: "Dietary Preference",
                    options: diets,
                    selections: store.selectedDiets,
                    action: OnboardingFeature.Action.dietTapped
                )
                .padding(.top, 40)
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
            .padding(.bottom, 16)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var isContinueEnabled: Bool {
        !store.selectedReligions.isEmpty && !store.selectedDiets.isEmpty
    }

    private func optionSection(
        title: String,
        options: [String],
        selections: Set<String>,
        action: @escaping (String) -> OnboardingFeature.Action
    ) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .applyEatzyFont(.button_18_m)
                .foregroundStyle(.gray700)

            OnboardingFlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    EatzyButtonOption(
                        option,
                        state: selections.contains(option) ? .selected : .unselected
                    ) {
                        store.send(action(option))
                    }
                }
            }
        }
    }
}

struct OnboardingFlowLayout: Layout {
    let spacing: CGFloat

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
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> (size: CGSize, points: [CGPoint]) {
        let maximumWidth = proposal.width ?? .infinity
        var points: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maximumWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            points.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return (
            CGSize(width: proposal.width ?? x, height: y + rowHeight),
            points
        )
    }
}
