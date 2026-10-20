//
//  MainTabFeature.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import Foundation

struct MainTabFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        enum Tab: Hashable {
            case menu
            case map
        }

        var selectedTab: Tab = .menu
        var selectedDate = Calendar.current.startOfDay(for: .now)
        var preferredUniversityCode: String
        var selectedUniversityCode: String
        var selectedCafeteriaCode = ""
        var catalogUniversities: [CatalogUniversityDTO] = []
        var isCatalogLoading = false
        var catalogErrorMessage: String?
        var mealsResponse: MealsResponseDTO?
        var dietaryProfile: DietaryProfileDTO?
        var dietaryTaxonomy: DietaryTaxonomyResponseDTO?
        var isDietaryFilterLoading = false
        var hasLoadedDietaryFilter = false
        var isMealsLoading = false
        var mealsErrorMessage: String?
        var isMenuSheetPresented = false
        var menuSheet = MenuSheetFeature.State()
        var isSettingPresented = false
        var map: MapFeature.State
        var setting: SettingFeature.State

        init(
            isAuthenticated: Bool = true,
            universityCode: String = "",
            dietaryProfile: DietaryProfileDTO? = nil,
            dietaryTaxonomy: DietaryTaxonomyResponseDTO? = nil
        ) {
            preferredUniversityCode = universityCode
            selectedUniversityCode = universityCode
            self.dietaryProfile = dietaryProfile
            self.dietaryTaxonomy = dietaryTaxonomy
            hasLoadedDietaryFilter = dietaryProfile != nil && dietaryTaxonomy != nil
            map = MapFeature.State(universityCode: universityCode)
            setting = SettingFeature.State(
                isAuthenticated: isAuthenticated,
                universityCode: universityCode,
                dietaryProfile: dietaryProfile,
                dietaryTaxonomy: dietaryTaxonomy
            )
        }

        var cafeterias: [CatalogCafeteriaDTO] {
            catalogUniversities
                .first(where: { $0.code == selectedUniversityCode })?
                .cafeterias ?? []
        }

        var isMenuAvailable: Bool {
            mealsResponse?.meals.contains { meal in
                meal.options.contains { !$0.items.isEmpty || $0.notice != nil }
            } == true
        }

    }

    @CasePathable
    enum Action {
        case tabSelected(State.Tab)
        case menuViewAppeared
        case dietaryProfileResponse(Result<DietaryProfileDTO, NetworkError>)
        case dietaryTaxonomyResponse(Result<DietaryTaxonomyResponseDTO, NetworkError>)
        case catalogRetryTapped
        case catalogResponse(Result<CatalogResponseDTO, NetworkError>)
        case loadMeals
        case mealsRetryTapped
        case mealsResponse(
            universityCode: String,
            cafeteriaCode: String,
            date: String,
            Result<MealsResponseDTO, NetworkError>
        )
        case dateSelected(Date)
        case cafeteriaSelected(String)
        case menuSectionTapped(String)
        case menuSheetPresentationChanged(Bool)
        case menuSheet(MenuSheetFeature.Action)
        case settingButtonTapped
        case map(MapFeature.Action)
        case setting(SettingFeature.Action)
        case delegate(Delegate)

        enum Delegate {
            case loginRequired
            case logoutCompleted
            case deleteAccountCompleted
        }
    }

    @Dependency(\.catalogClient) private var catalogClient
    @Dependency(\.mealsClient) private var mealsClient
    @Dependency(\.dietaryProfileClient) private var dietaryProfileClient
    @Dependency(\.dietaryClient) private var dietaryClient

    nonisolated private enum CancelID: Hashable, Sendable {
        case meals
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.menuSheet, action: \.menuSheet) {
            MenuSheetFeature()
        }

        Scope(state: \.map, action: \.map) {
            MapFeature()
        }

        Scope(state: \.setting, action: \.setting) {
            SettingFeature()
        }

        Reduce { state, action in
            switch action {
            case .menuViewAppeared:
                var effects: [Effect<Action>] = []

                if state.catalogUniversities.isEmpty, !state.isCatalogLoading {
                    state.isCatalogLoading = true
                    state.catalogErrorMessage = nil
                    effects.append(
                        .run { send in
                            do {
                                let response = try await catalogClient.fetch("en")
                                await send(.catalogResponse(.success(response)))
                            } catch {
                                await send(
                                    .catalogResponse(
                                        .failure(error as? NetworkError ?? .unknownError)
                                    )
                                )
                            }
                        }
                    )
                }

                if state.setting.isAuthenticated,
                   !state.hasLoadedDietaryFilter,
                   !state.isDietaryFilterLoading {
                    state.isDietaryFilterLoading = true
                    effects.append(
                        .run { send in
                            async let profile = dietaryProfileClient.fetch()
                            async let taxonomy = dietaryClient.fetchTaxonomy()
                            do {
                                await send(.dietaryProfileResponse(.success(try await profile)))
                                await send(.dietaryTaxonomyResponse(.success(try await taxonomy)))
                            } catch {
                                let networkError = error as? NetworkError ?? .unknownError
                                await send(.dietaryProfileResponse(.failure(networkError)))
                                await send(.dietaryTaxonomyResponse(.failure(networkError)))
                            }
                        }
                    )
                }

                return .merge(effects)

            case let .dietaryProfileResponse(.success(profile)):
                state.dietaryProfile = profile
                state.isDietaryFilterLoading = false
                state.hasLoadedDietaryFilter = state.dietaryTaxonomy != nil
                return .none

            case .dietaryProfileResponse(.failure):
                state.isDietaryFilterLoading = false
                return .none

            case let .dietaryTaxonomyResponse(.success(taxonomy)):
                state.dietaryTaxonomy = taxonomy
                state.isDietaryFilterLoading = false
                state.hasLoadedDietaryFilter = state.dietaryProfile != nil
                return .none

            case .dietaryTaxonomyResponse(.failure):
                state.isDietaryFilterLoading = false
                return .none

            case .catalogRetryTapped:
                state.catalogUniversities = []
                state.isCatalogLoading = false
                return .send(.menuViewAppeared)

            case let .catalogResponse(.success(response)):
                state.isCatalogLoading = false
                state.catalogUniversities = response.universities
                let university = response.universities.first {
                    $0.code == state.selectedUniversityCode
                } ?? response.universities.first {
                    $0.code == state.preferredUniversityCode
                }
                state.selectedUniversityCode = university?.code ?? ""
                state.map.universityCode = university?.code ?? ""
                state.map.selectedUniversity = university.map {
                    $0.name ?? $0.nameEn ?? $0.nameKo ?? $0.code.uppercased()
                } ?? ""
                let containsSelectedCafeteria = university?.cafeterias.contains {
                    $0.code == state.selectedCafeteriaCode
                } == true
                if !containsSelectedCafeteria {
                    state.selectedCafeteriaCode = university?.cafeterias.first?.code ?? ""
                }
                return .send(.loadMeals)

            case let .catalogResponse(.failure(error)):
                state.isCatalogLoading = false
                state.catalogErrorMessage = error.description
                return .none

            case .loadMeals:
                guard
                    !state.selectedUniversityCode.isEmpty,
                    !state.selectedCafeteriaCode.isEmpty
                else {
                    state.mealsResponse = nil
                    return .none
                }

                let universityCode = state.selectedUniversityCode
                let cafeteriaCode = state.selectedCafeteriaCode
                let date = Self.dateString(from: state.selectedDate)
                state.isMealsLoading = true
                state.mealsErrorMessage = nil
                state.mealsResponse = nil

                return .run { send in
                    do {
                        let response = try await mealsClient.fetch(
                            universityCode,
                            cafeteriaCode,
                            date,
                            "en"
                        )
                        await send(
                            .mealsResponse(
                                universityCode: universityCode,
                                cafeteriaCode: cafeteriaCode,
                                date: date,
                                .success(response)
                            )
                        )
                    } catch {
                        await send(
                            .mealsResponse(
                                universityCode: universityCode,
                                cafeteriaCode: cafeteriaCode,
                                date: date,
                                .failure(error as? NetworkError ?? .unknownError)
                            )
                        )
                    }
                }
                .cancellable(id: CancelID.meals, cancelInFlight: true)

            case .mealsRetryTapped:
                return .send(.loadMeals)

            case let .mealsResponse(universityCode, cafeteriaCode, date, result):
                guard
                    universityCode == state.selectedUniversityCode,
                    cafeteriaCode == state.selectedCafeteriaCode,
                    date == Self.dateString(from: state.selectedDate)
                else {
                    return .none
                }
                state.isMealsLoading = false
                switch result {
                case let .success(response):
                    state.mealsResponse = response
                    state.mealsErrorMessage = nil
                case let .failure(error):
                    state.mealsResponse = nil
                    state.mealsErrorMessage = error.description
                }
                return .none

            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case let .dateSelected(date):
                state.selectedDate = date
                return .send(.loadMeals)

            case let .cafeteriaSelected(cafeteria):
                state.selectedCafeteriaCode = cafeteria
                return .send(.loadMeals)

            case let .menuSectionTapped(sectionID):
                guard let detail = MealsPresentation.sheet(
                    for: sectionID,
                    in: state.mealsResponse,
                    dietaryProfile: state.dietaryProfile,
                    taxonomy: state.dietaryTaxonomy,
                    appliesDietaryFilter: state.setting.dietaryPreference.savedShowsOnMenu
                ) else {
                    return .none
                }
                state.menuSheet = MenuSheetFeature.State(
                    selectedSectionID: sectionID,
                    detail: detail
                )
                state.isMenuSheetPresented = true
                return .none

            case let .menuSheetPresentationChanged(isPresented):
                state.isMenuSheetPresented = isPresented
                return .none

            case .menuSheet(.delegate(.dismissRequested)):
                state.isMenuSheetPresented = false
                return .none

            case .menuSheet:
                return .none

            case .settingButtonTapped, .map(.delegate(.settingRequested)):
                state.isSettingPresented = true
                return .none

            case let .map(.delegate(.menuRequested(cafeteriaCode))):
                state.selectedUniversityCode = state.map.universityCode
                state.selectedCafeteriaCode = cafeteriaCode
                state.selectedTab = .menu
                return .send(.loadMeals)

            case .map:
                return .none

            case .setting(.delegate(.backRequested)):
                state.isSettingPresented = false
                return .none

            case .setting(.delegate(.loginRequired)):
                return .send(.delegate(.loginRequired))

            case .setting(.delegate(.logoutCompleted)):
                return .send(.delegate(.logoutCompleted))

            case .setting(.delegate(.deleteAccountCompleted)):
                return .send(.delegate(.deleteAccountCompleted))

            case let .setting(.delegate(.universityChanged(code, name))):
                state.preferredUniversityCode = code
                state.selectedUniversityCode = code
                state.mealsResponse = nil
                state.mealsErrorMessage = nil

                let university = state.catalogUniversities.first {
                    $0.code == code
                }
                state.selectedCafeteriaCode = university?.cafeterias.first?.code ?? ""

                let menuEffect: Effect<Action> = state.catalogUniversities.isEmpty
                    ? .send(.menuViewAppeared)
                    : .send(.loadMeals)

                return .merge(
                    menuEffect,
                    .send(.map(.universityChanged(code: code, name: name)))
                )

            case let .setting(.delegate(.dietaryProfileUpdated(profile))):
                state.dietaryProfile = profile
                state.hasLoadedDietaryFilter = state.dietaryTaxonomy != nil
                return .none

            case .setting:
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private static func dateString(from date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }
}
