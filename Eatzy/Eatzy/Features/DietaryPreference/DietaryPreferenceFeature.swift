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
        var savedShowsOnMenu = true
        var savedReligions: Set<String> = []
        var savedDiets: Set<String> = []
        var savedRestrictions: Set<String> = []
        var maxSpiceLevel: Int?
        var isLoading = false
        var isProfileLoading = false
        var hasLoadedDietaryProfile = false
        var isSaving = false
        var isDiscardAlertPresented = false
        var errorMessage: String?
        var saveErrorMessage: String?

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

        var hasChanges: Bool {
            showsOnMenu != savedShowsOnMenu ||
                selectedReligions != savedReligions ||
                selectedDiets != savedDiets ||
                selectedRestrictions != savedRestrictions
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
        case doneButtonTapped
        case replaceProfileResponse(Result<DietaryProfileDTO, NetworkError>)
        case discardAlertPresentationChanged(Bool)
        case discardChangesButtonTapped
        case cancelDiscardButtonTapped
        case saveErrorDismissed
        case backButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case backRequested
            case profileUpdated(DietaryProfileDTO)
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
                state.savedReligions = state.selectedReligions
                state.savedDiets = state.selectedDiets
                state.savedRestrictions = state.selectedRestrictions
                state.maxSpiceLevel = response.maxSpiceLevel
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

            case .doneButtonTapped:
                guard state.hasChanges, !state.isSaving else { return .none }

                let request = DietaryProfileDTO(
                    avoidedIngredients: state.selectedRestrictions.sorted(),
                    diets: state.selectedDiets.sorted(),
                    maxSpiceLevel: state.maxSpiceLevel,
                    religion: state.selectedReligions.first
                )

                if !state.isAuthenticated {
                    return .send(.replaceProfileResponse(.success(request)))
                }

                state.isSaving = true
                state.saveErrorMessage = nil
                return .run { send in
                    do {
                        await send(
                            .replaceProfileResponse(
                                .success(try await dietaryProfileClient.replace(request))
                            )
                        )
                    } catch {
                        await send(
                            .replaceProfileResponse(
                                .failure(error as? NetworkError ?? .unknownError)
                            )
                        )
                    }
                }

            case let .replaceProfileResponse(.success(response)):
                state.isSaving = false
                state.saveErrorMessage = nil
                state.selectedReligions = response.religion.map { [$0] } ?? []
                state.selectedDiets = Set(response.diets)
                state.selectedRestrictions = Set(response.avoidedIngredients)
                state.savedShowsOnMenu = state.showsOnMenu
                state.savedReligions = state.selectedReligions
                state.savedDiets = state.selectedDiets
                state.savedRestrictions = state.selectedRestrictions
                state.maxSpiceLevel = response.maxSpiceLevel
                return .send(.delegate(.profileUpdated(response)))

            case let .replaceProfileResponse(.failure(error)):
                state.isSaving = false
                state.saveErrorMessage = error.description
                return .none

            case let .discardAlertPresentationChanged(isPresented):
                state.isDiscardAlertPresented = isPresented
                return .none

            case .discardChangesButtonTapped:
                state.showsOnMenu = state.savedShowsOnMenu
                state.selectedReligions = state.savedReligions
                state.selectedDiets = state.savedDiets
                state.selectedRestrictions = state.savedRestrictions
                state.isDiscardAlertPresented = false
                return .send(.delegate(.backRequested))

            case .cancelDiscardButtonTapped:
                state.isDiscardAlertPresented = false
                return .none

            case .saveErrorDismissed:
                state.saveErrorMessage = nil
                return .none

            case .backButtonTapped:
                guard !state.hasChanges else {
                    state.isDiscardAlertPresented = true
                    return .none
                }
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
