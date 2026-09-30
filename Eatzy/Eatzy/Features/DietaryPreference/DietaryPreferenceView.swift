//
//  DietaryPreferenceView.swift
//  Eatzy
//
//  Created by sun on 10/1/26.
//

import ComposableArchitecture
import SwiftUI

struct DietaryPreferenceView: View {
    let store: StoreOf<DietaryPreferenceFeature>

    var body: some View {
        VStack(spacing: 0) {
            EatzyNavigationBar(
                leading: .back {
                    store.send(.backButtonTapped)
                }
            )

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Dietary Preferences")
                        .applyEatzyFont(.display_22_sb)
                        .foregroundStyle(.coreBlack)
                        .padding(.top, 24)

                    HStack(spacing: 8) {
                        Text("Show on menu")
                            .applyEatzyFont(.body_16_r)
                            .foregroundStyle(.gray900)

                        Spacer(minLength: 0)

                        EatzyToggle(isOn: showsOnMenu)
                    }
                    .padding(.top, 20)

                    if store.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 42)
                    } else if let message = store.errorMessage {
                        errorView(message)
                    } else {
                        preferenceContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.coreWhite)
        .task {
            await store.send(.viewAppeared).finish()
        }
    }
}

private extension DietaryPreferenceView {
    var preferenceContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            dropdownSection(
                title: "Religious Preference",
                dropdownTitle: religionTitle,
                options: store.religionOptions,
                selections: religionSelections,
                optionTitle: { religionName(for: $0) }
            )
            .padding(.top, 42)

            dropdownSection(
                title: "Dietary Preference",
                dropdownTitle: dietTitle,
                options: store.dietOptions,
                selections: dietSelections,
                optionTitle: { dietName(for: $0) }
            )
            .padding(.top, 40)

            VStack(alignment: .leading, spacing: 20) {
                Text("Dietary Preference")
                    .applyEatzyFont(.display_16_sb)
                    .foregroundStyle(.gray900)

                OnboardingFlowLayout(horizontalSpacing: 8, verticalSpacing: 16) {
                    noRestrictionButton

                    ForEach(store.restrictionOptions, id: \.code) { ingredient in
                        EatzyButtonOption(
                            "No \(ingredient.nameEn)",
                            state: store.selectedRestrictions.contains(ingredient.code)
                                ? .selected
                                : .unselected
                        ) {
                            store.send(.restrictionTapped(ingredient.code))
                        }
                    }
                }
            }
            .padding(.top, 40)
        }
    }

    func dropdownSection(
        title: String,
        dropdownTitle: String,
        options: [String],
        selections: Binding<Set<String>>,
        optionTitle: @escaping (String) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .applyEatzyFont(.display_16_sb)
                .foregroundStyle(.gray900)

            EatzyDropdown(
                title: dropdownTitle,
                options: options,
                selections: selections,
                optionTitle: optionTitle
            )
        }
    }

    var noRestrictionButton: some View {
        EatzyButtonOption(
            "No Restriction",
            state: store.selectedRestrictions.isEmpty ? .selected : .unselected
        ) {
            store.send(.clearRestrictionsTapped)
        }
    }

    var showsOnMenu: Binding<Bool> {
        Binding(
            get: { store.showsOnMenu },
            set: { store.send(.showsOnMenuChanged($0)) }
        )
    }

    var religionSelections: Binding<Set<String>> {
        Binding(
            get: { store.selectedReligions },
            set: { store.send(.religionSelectionChanged($0)) }
        )
    }

    var dietSelections: Binding<Set<String>> {
        Binding(
            get: { store.selectedDiets },
            set: { store.send(.dietSelectionChanged($0)) }
        )
    }

    var religionTitle: String {
        selectionTitle(
            store.selectedReligions,
            name: { religionName(for: $0) }
        )
    }

    var dietTitle: String {
        selectionTitle(
            store.selectedDiets,
            name: { dietName(for: $0) }
        )
    }

    func religionName(for code: String) -> String {
        store.taxonomy?.religions.first(where: { $0.code == code })?.nameEn ?? code
    }

    func dietName(for code: String) -> String {
        store.taxonomy?.diets.first(where: { $0.code == code })?.nameEn ?? code
    }

    func selectionTitle(
        _ selections: Set<String>,
        name: (String) -> String
    ) -> String {
        let titles = selections.sorted().map(name)
        return titles.isEmpty ? "Please Select" : titles.joined(separator: ", ")
    }

    func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .applyEatzyFont(.body_14_r)
                .foregroundStyle(.gray500)

            Button("Retry") {
                store.send(.retryButtonTapped)
            }
            .applyEatzyFont(.button_14_m)
            .foregroundStyle(.orange500)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 42)
    }
}

#Preview {
    DietaryPreferenceView(
        store: Store(initialState: DietaryPreferenceFeature.State()) {
            DietaryPreferenceFeature()
        }
    )
}
