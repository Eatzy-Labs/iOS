//
//  MainTabFeature.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import Foundation

struct MainTabFeature: Reducer {
    static let cafeterias = [
        "114(Cheomseong)",
        "305(Welfare)",
        "116(Info)",
        "408(Engineer)",
        "109(FastFood)",
        "103(GP)"
    ]

    @ObservableState
    struct State: Equatable {
        enum Tab: Hashable {
            case menu
            case map
        }

        var selectedTab: Tab = .menu
        var selectedDate = Calendar.current.startOfDay(for: .now)
        var selectedCafeteria = MainTabFeature.cafeterias.first ?? ""
        var availableMenuDates: Set<Date> = [Calendar.current.startOfDay(for: .now)]
        var selectedBreakfastSectionID: String?
        var selectedLunchSectionID: String?
        var selectedDinnerSectionID: String?
        var selectedUniversity = "Kyungpook Univ"
        var mapPlaces = MapMockData.places
        var selectedMapCategory: MapPlace.Category = .all
        var isMapVisible = false
        var isSettingPresented = false
        var isAuthenticated = true

        var isMenuAvailable: Bool {
            let selectedDay = Calendar.current.startOfDay(for: selectedDate)

            return availableMenuDates.contains(selectedDay)
                && selectedCafeteria == MainTabFeature.cafeterias.first
        }

        var visibleMapPlaces: [MapPlace] {
            guard selectedMapCategory != .all else {
                return mapPlaces
            }

            return mapPlaces.filter { $0.category == selectedMapCategory }
        }
    }

    enum Action {
        case tabSelected(State.Tab)
        case dateSelected(Date)
        case cafeteriaSelected(String)
        case breakfastSectionSelected(String?)
        case lunchSectionSelected(String?)
        case dinnerSectionSelected(String?)
        case settingButtonTapped
        case settingBackButtonTapped
        case settingLoginButtonTapped
        case mapViewAppeared
        case mapUniversityTapped
        case mapSettingButtonTapped
        case mapCategorySelected(MapPlace.Category)
        case delegate(Delegate)

        enum Delegate {
            case loginRequired
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case let .dateSelected(date):
                state.selectedDate = date
                state.selectedCafeteria = Self.cafeterias.first ?? ""
                resetMenuSelections(&state)
                return .none

            case let .cafeteriaSelected(cafeteria):
                state.selectedCafeteria = cafeteria
                resetMenuSelections(&state)
                return .none

            case let .breakfastSectionSelected(sectionID):
                state.selectedBreakfastSectionID = sectionID
                return .none

            case let .lunchSectionSelected(sectionID):
                state.selectedLunchSectionID = sectionID
                return .none

            case let .dinnerSectionSelected(sectionID):
                state.selectedDinnerSectionID = sectionID
                return .none

            case .settingButtonTapped, .mapSettingButtonTapped:
                state.isSettingPresented = true
                return .none

            case .settingBackButtonTapped:
                state.isSettingPresented = false
                return .none

            case .settingLoginButtonTapped:
                return .send(.delegate(.loginRequired))

            case .mapViewAppeared:
                state.isMapVisible = true
                return .none

            case .mapUniversityTapped:
                return .none

            case let .mapCategorySelected(category):
                state.selectedMapCategory = category
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private func resetMenuSelections(_ state: inout State) {
        state.selectedBreakfastSectionID = nil
        state.selectedLunchSectionID = nil
        state.selectedDinnerSectionID = nil
    }
}
