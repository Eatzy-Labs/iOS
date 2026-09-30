//
//  DietaryPreferenceFeature.swift
//  Eatzy
//
//  Created by sun on 10/1/26.
//

import ComposableArchitecture

struct DietaryPreferenceFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var isAuthenticated: Bool
        var showsOnMenu = true
        var taxonomy: DietaryTaxonomyResponseDTO?
        var selectedReligions: Set<String> = []
        var selectedDiets: Set<String> = []
        var selectedRestrictions: Set<String> = []
        var isLoading = false
        var isProfileLoading = false
        var hasLoadedDietaryProfile = false
        var errorMessage: String?

        init(isAuthenticated: Bool = true) {
            self.isAuthenticated = isAuthenticated
        }

        var religionOptions: [String] {
            taxonomy?.religions.map(\.code) ?? []
        }

        var dietOptions: [String] {
            taxonomy?.diets.map(\.code) ?? []
        }

        var restrictionOptions: [IngredientDTO] {
            taxonomy?.ingredients ?? []
        }

        func religionName(for code: String) -> String {
            taxonomy?.religions.first(where: { $0.code == code })?.nameEn ?? code
        }

        func dietName(for code: String) -> String {
            taxonomy?.diets.first(where: { $0.code == code })?.nameEn ?? code
        }
    }

    enum Action {
        case viewAppeared
        case retryButtonTapped
        case taxonomyResponse(Result<DietaryTaxonomyResponseDTO, NetworkError>)
        case dietaryProfileResponse(Result<DietaryProfileDTO, NetworkError>)
        case showsOnMenuChanged(Bool)
        case religionSelectionChanged(Set<String>)
        case dietSelectionChanged(Set<String>)
        case restrictionTapped(String)
        case clearRestrictionsTapped
        case backButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case backRequested
        }
    }

    @Dependency(\.dietaryClient) private var dietaryClient
    @Dependency(\.dietaryProfileClient) private var dietaryProfileClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewAppeared:
                state.errorMessage = nil
                var effects: [Effect<Action>] = []

                if state.taxonomy == nil, !state.isLoading {
                    state.isLoading = true
                    effects.append(
                        .run { send in
                            do {
                                await send(
                                    .taxonomyResponse(
                                        .success(try await dietaryClient.fetchTaxonomy())
                                    )
                                )
                            } catch {
                                await send(
                                    .taxonomyResponse(
                                        .failure(error as? NetworkError ?? .unknownError)
                                    )
                                )
                            }
                        }
                    )
                }

                if state.isAuthenticated,
                   !state.hasLoadedDietaryProfile,
                   !state.isProfileLoading {
                    state.isProfileLoading = true
                    effects.append(
                        .run { send in
                            do {
                                await send(
                                    .dietaryProfileResponse(
                                        .success(try await dietaryProfileClient.fetch())
                                    )
                                )
                            } catch {
                                await send(
                                    .dietaryProfileResponse(
                                        .failure(error as? NetworkError ?? .unknownError)
                                    )
                                )
                            }
                        }
                    )
                }

                return .merge(effects)

            case .retryButtonTapped:
                state.taxonomy = nil
                state.hasLoadedDietaryProfile = false
                state.isLoading = false
                state.isProfileLoading = false
                return .send(.viewAppeared)

            case let .taxonomyResponse(.success(response)):
                state.isLoading = false
                state.taxonomy = response
                return .none

            case let .taxonomyResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.description
                return .none

            case let .dietaryProfileResponse(.success(response)):
                state.isProfileLoading = false
                state.hasLoadedDietaryProfile = true
                state.selectedReligions = response.religion.map { [$0] } ?? []
                state.selectedDiets = Set(response.diets)
                state.selectedRestrictions = Set(response.avoidedIngredients)
                return .none

            case let .dietaryProfileResponse(.failure(error)):
                state.isProfileLoading = false
                state.errorMessage = error.description
                return .none

            case let .showsOnMenuChanged(isOn):
                state.showsOnMenu = isOn
                return .none

            case let .religionSelectionChanged(selection):
                state.selectedReligions = singleSelection(
                    from: selection,
                    previous: state.selectedReligions
                )
                return .none

            case let .dietSelectionChanged(selection):
                state.selectedDiets = selection
                return .none

            case let .restrictionTapped(code):
                if state.selectedRestrictions.contains(code) {
                    state.selectedRestrictions.remove(code)
                } else {
                    state.selectedRestrictions.insert(code)
                }
                return .none

            case .clearRestrictionsTapped:
                state.selectedRestrictions = []
                return .none

            case .backButtonTapped:
                return .send(.delegate(.backRequested))

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
}
