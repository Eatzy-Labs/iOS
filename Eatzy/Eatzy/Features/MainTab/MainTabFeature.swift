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
        var selectedCafeteria = "114(Cheomseong)"
        var selectedBreakfastSectionID: String?
        var selectedLunchSectionID: String?
        var selectedDinnerSectionID: String?
    }

    enum Action {
        case tabSelected(State.Tab)
        case dateSelected(Date)
        case cafeteriaSelected(String)
        case breakfastSectionSelected(String?)
        case lunchSectionSelected(String?)
        case dinnerSectionSelected(String?)
        case settingButtonTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case let .dateSelected(date):
                state.selectedDate = date
                return .none

            case let .cafeteriaSelected(cafeteria):
                state.selectedCafeteria = cafeteria
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

            case .settingButtonTapped:
                return .none
            }
        }
    }
}
