//
//  OnboardingFeature.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture

struct OnboardingFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        enum EntryPoint: Equatable {
            case signUp
            case guest

            var completionButtonTitle: String {
                switch self {
                case .signUp: return "Sign Up"
                case .guest: return "Get Started"
                }
            }
        }

        enum Step: Equatable {
            case university
            case country
            case preference
            case restriction
        }

        var entryPoint: EntryPoint = .signUp
        var step: Step = .university
        var selectedUniversity: Set<String> = []
        var selectedCountry: Set<String> = []
        var selectedReligions: Set<String> = []
        var selectedDiets: Set<String> = []
        var selectedFoodRestrictions: Set<String> = []
    }

    enum Action {
        case universitySelectionChanged(Set<String>)
        case countrySelectionChanged(Set<String>)
        case religionTapped(String)
        case dietTapped(String)
        case foodRestrictionTapped(String)
        case continueButtonTapped
        case backButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case backToLogin
            case onboardingCompleted
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .universitySelectionChanged(selection):
                state.selectedUniversity = singleSelection(
                    from: selection,
                    previous: state.selectedUniversity
                )
                return .none

            case let .countrySelectionChanged(selection):
                state.selectedCountry = singleSelection(
                    from: selection,
                    previous: state.selectedCountry
                )
                return .none

            case let .religionTapped(religion):
                toggle(religion, in: &state.selectedReligions)
                return .none

            case let .dietTapped(diet):
                toggle(diet, in: &state.selectedDiets)
                return .none

            case let .foodRestrictionTapped(restriction):
                toggleFoodRestriction(restriction, in: &state.selectedFoodRestrictions)
                return .none

            case .continueButtonTapped:
                switch state.step {
                case .university where !state.selectedUniversity.isEmpty:
                    state.step = .country
                case .country where !state.selectedCountry.isEmpty:
                    state.step = .preference
                case .preference where !state.selectedReligions.isEmpty && !state.selectedDiets.isEmpty:
                    state.step = .restriction
                case .restriction where !state.selectedFoodRestrictions.isEmpty:
                    return .send(.delegate(.onboardingCompleted))
                default:
                    break
                }
                return .none

            case .backButtonTapped:
                switch state.step {
                case .university:
                    return .send(.delegate(.backToLogin))
                case .country:
                    state.step = .university
                case .preference:
                    state.step = .country
                case .restriction:
                    state.step = .preference
                }
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private func singleSelection(
        from selection: Set<String>,
        previous: Set<String>
    ) -> Set<String> {
        if let newlySelected = selection.subtracting(previous).first {
            return [newlySelected]
        }
        return selection.first.map { [$0] } ?? []
    }

    private func toggle(_ option: String, in selection: inout Set<String>) {
        if selection.contains(option) {
            selection.remove(option)
        } else {
            selection.insert(option)
        }
    }

    private func toggleFoodRestriction(
        _ restriction: String,
        in selection: inout Set<String>
    ) {
        if restriction == "No Restriction" {
            selection = selection.contains(restriction) ? [] : [restriction]
            return
        }

        selection.remove("No Restriction")
        toggle(restriction, in: &selection)
    }
}
