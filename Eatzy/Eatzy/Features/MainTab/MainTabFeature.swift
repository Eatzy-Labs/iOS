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
        var isMealsLoading = false
        var mealsErrorMessage: String?
        var selectedMenuSectionID: String?
        var isMenuSheetPresented = false
        var menuSheet = MenuSheetFeature.State()
        var isSettingPresented = false
        var map = MapFeature.State()
        var setting: SettingFeature.State

        init(isAuthenticated: Bool = true, universityCode: String = "knu") {
            preferredUniversityCode = universityCode
            selectedUniversityCode = universityCode
            setting = SettingFeature.State(
                isAuthenticated: isAuthenticated,
                universityCode: universityCode
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
        case menuSectionSelectionChanged(String?)
        case menuSectionTapped(String)
        case menuSheetPresentationChanged(Bool)
        case menuSheet(MenuSheetFeature.Action)
        case settingButtonTapped
        case map(MapFeature.Action)
        case setting(SettingFeature.Action)
        case delegate(Delegate)

        enum Delegate {
            case loginRequired
        }
    }

    @Dependency(\.catalogClient) private var catalogClient
    @Dependency(\.mealsClient) private var mealsClient

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
                guard state.catalogUniversities.isEmpty, !state.isCatalogLoading else {
                    return .none
                }
                state.isCatalogLoading = true
                state.catalogErrorMessage = nil
                return .run { send in
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

            case .catalogRetryTapped:
                state.catalogUniversities = []
                state.isCatalogLoading = false
                return .send(.menuViewAppeared)

            case let .catalogResponse(.success(response)):
                state.isCatalogLoading = false
                state.catalogUniversities = response.universities
                let university = response.universities.first {
                    $0.code == state.preferredUniversityCode
                } ?? response.universities.first
                state.selectedUniversityCode = university?.code ?? ""
                state.selectedCafeteriaCode = university?.cafeterias.first?.code ?? ""
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
                resetMenuSelections(&state)
                return .send(.loadMeals)

            case let .cafeteriaSelected(cafeteria):
                state.selectedCafeteriaCode = cafeteria
                resetMenuSelections(&state)
                return .send(.loadMeals)

            case let .menuSectionSelectionChanged(sectionID):
                state.selectedMenuSectionID = sectionID
                return .none

            case let .menuSectionTapped(sectionID):
                guard let detail = MealsPresentation.sheet(
                    for: sectionID,
                    in: state.mealsResponse
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

            case .map:
                return .none

            case .setting(.delegate(.backRequested)):
                state.isSettingPresented = false
                return .none

            case .setting(.delegate(.loginRequired)):
                return .send(.delegate(.loginRequired))

            case .setting:
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private func resetMenuSelections(_ state: inout State) {
        state.selectedMenuSectionID = nil
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
