//
//  OnboardingFeature.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import Foundation

struct OnboardingFeature: Reducer {
    struct Option: Equatable, Identifiable {
        let id: String
        let title: String
    }

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
        var countrySearchText = ""
        var selectedReligions: Set<String> = []
        var selectedDiets: Set<String> = []
        var selectedFoodRestrictions: Set<String> = []
        var universities: [UniversitySummaryDTO] = []
        var isUniversitiesLoading = false
        var universitiesErrorMessage: String?
        var countries: [CountryDTO] = []
        var isCountriesLoading = false
        var countriesErrorMessage: String?
        var taxonomy: DietaryTaxonomyResponseDTO?
        var isTaxonomyLoading = false
        var taxonomyErrorMessage: String?

        var religionOptions: [Option] {
            [Option(id: Self.noneCode, title: "No Preference")] +
                (taxonomy?.religions.map { Option(id: $0.code, title: $0.nameEn) } ?? [])
        }

        var dietOptions: [Option] {
            [Option(id: Self.noneCode, title: "No Preference")] +
                (taxonomy?.diets.map { Option(id: $0.code, title: $0.nameEn) } ?? [])
        }

        var restrictionOptions: [Option] {
            [Option(id: Self.noneCode, title: "No Restriction")] +
                (taxonomy?.ingredients.map {
                    Option(id: $0.code, title: "No \($0.nameEn)")
                } ?? [])
        }

        var universityOptions: [String] {
            universities.map(\.code)
        }

        var selectedUniversityTitle: String {
            guard let code = selectedUniversity.first else {
                return "Please Select"
            }
            return universities.first(where: { $0.code == code })?.nameEn ?? code
        }

        var countryOptions: [String] {
            countries.map(\.code)
        }

        var filteredCountries: [CountryDTO] {
            let query = countrySearchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty else { return countries }

            return countries.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                    $0.code.localizedCaseInsensitiveContains(query)
            }
        }

        var selectedCountryTitle: String {
            guard let code = selectedCountry.first else {
                return "Please Select"
            }
            return countries.first(where: { $0.code == code })?.name ?? code
        }

        var dietaryProfile: DietaryProfileDTO {
            DietaryProfileDTO(
                avoidedIngredients: selectedFoodRestrictions
                    .filter { $0 != Self.noneCode }
                    .sorted(),
                diets: selectedDiets
                    .filter { $0 != Self.noneCode }
                    .sorted(),
                maxSpiceLevel: taxonomy?.spiceScale.max,
                religion: selectedReligions.first.flatMap {
                    $0 == Self.noneCode ? nil : $0
                }
            )
        }

        fileprivate static let noneCode = "NONE"
    }

    enum Action {
        case viewAppeared
        case universitiesRetryTapped
        case universitiesResponse(Result<UniversitiesResponseDTO, NetworkError>)
        case countriesRetryTapped
        case countriesResponse(Result<CountriesResponseDTO, NetworkError>)
        case taxonomyRetryTapped
        case taxonomyResponse(Result<DietaryTaxonomyResponseDTO, NetworkError>)
        case universitySelectionChanged(Set<String>)
        case countrySelectionChanged(Set<String>)
        case countrySearchTextChanged(String)
        case countryTapped(String)
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

    @Dependency(\.dietaryClient) private var dietaryClient
    @Dependency(\.catalogClient) private var catalogClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewAppeared:
                var effects: [Effect<Action>] = []

                if state.universities.isEmpty, !state.isUniversitiesLoading {
                    state.isUniversitiesLoading = true
                    state.universitiesErrorMessage = nil
                    effects.append(
                        .run { send in
                            do {
                                await send(
                                    .universitiesResponse(
                                        .success(try await catalogClient.fetchUniversities())
                                    )
                                )
                            } catch {
                                await send(
                                    .universitiesResponse(
                                        .failure(error as? NetworkError ?? .unknownError)
                                    )
                                )
                            }
                        }
                    )
                }

                if state.countries.isEmpty, !state.isCountriesLoading {
                    state.isCountriesLoading = true
                    state.countriesErrorMessage = nil
                    effects.append(
                        .run { send in
                            do {
                                await send(
                                    .countriesResponse(
                                        .success(try await catalogClient.fetchCountries("en"))
                                    )
                                )
                            } catch {
                                await send(
                                    .countriesResponse(
                                        .failure(error as? NetworkError ?? .unknownError)
                                    )
                                )
                            }
                        }
                    )
                }

                if state.taxonomy == nil, !state.isTaxonomyLoading {
                    state.isTaxonomyLoading = true
                    state.taxonomyErrorMessage = nil
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

                return .merge(effects)

            case .universitiesRetryTapped:
                state.universities = []
                state.isUniversitiesLoading = false
                return .send(.viewAppeared)

            case let .universitiesResponse(.success(response)):
                state.isUniversitiesLoading = false
                state.universitiesErrorMessage = nil
                state.universities = response.universities
                return .none

            case let .universitiesResponse(.failure(error)):
                state.isUniversitiesLoading = false
                state.universitiesErrorMessage = error.description
                return .none

            case .countriesRetryTapped:
                state.countries = []
                state.isCountriesLoading = false
                return .send(.viewAppeared)

            case let .countriesResponse(.success(response)):
                state.isCountriesLoading = false
                state.countriesErrorMessage = nil
                state.countries = response.countries
                return .none

            case let .countriesResponse(.failure(error)):
                state.isCountriesLoading = false
                state.countriesErrorMessage = error.description
                return .none

            case .taxonomyRetryTapped:
                state.taxonomy = nil
                state.isTaxonomyLoading = false
                return .send(.viewAppeared)

            case let .taxonomyResponse(.success(response)):
                state.isTaxonomyLoading = false
                state.taxonomyErrorMessage = nil
                state.taxonomy = response
                return .none

            case let .taxonomyResponse(.failure(error)):
                state.isTaxonomyLoading = false
                state.taxonomyErrorMessage = error.description
                return .none

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

            case let .countrySearchTextChanged(text):
                state.countrySearchText = text

                if let selectedCode = state.selectedCountry.first,
                   let selectedCountry = state.countries.first(where: { $0.code == selectedCode }),
                   selectedCountry.name != text {
                    state.selectedCountry = []
                }
                return .none

            case let .countryTapped(code):
                guard state.countries.contains(where: { $0.code == code }) else {
                    return .none
                }
                state.selectedCountry = [code]
                return .none

            case let .religionTapped(religion):
                selectSingleOption(religion, in: &state.selectedReligions)
                return .none

            case let .dietTapped(diet):
                toggleExclusiveOption(diet, in: &state.selectedDiets)
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
        if restriction == State.noneCode {
            selection = selection.contains(restriction) ? [] : [restriction]
            return
        }

        selection.remove(State.noneCode)
        toggle(restriction, in: &selection)
    }

    private func selectSingleOption(
        _ option: String,
        in selection: inout Set<String>
    ) {
        selection = selection.contains(option) ? [] : [option]
    }

    private func toggleExclusiveOption(
        _ option: String,
        in selection: inout Set<String>
    ) {
        if option == State.noneCode {
            selection = selection.contains(option) ? [] : [option]
            return
        }

        selection.remove(State.noneCode)
        toggle(option, in: &selection)
    }
}
