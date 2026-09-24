//
//  MapFeature.swift
//  Eatzy
//

import ComposableArchitecture

struct MapFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var selectedUniversity = "Kyungpook Univ"
        var places = MapMockData.places
        var selectedCategory: MapPlace.Category = .all
        var isVisible = false

        var visiblePlaces: [MapPlace] {
            guard selectedCategory != .all else {
                return places
            }

            return places.filter { $0.category == selectedCategory }
        }
    }

    enum Action {
        case viewAppeared
        case universityButtonTapped
        case settingButtonTapped
        case categorySelected(MapPlace.Category)
        case delegate(Delegate)

        enum Delegate {
            case settingRequested
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewAppeared:
                state.isVisible = true
                return .none

            case .universityButtonTapped:
                return .none

            case .settingButtonTapped:
                return .send(.delegate(.settingRequested))

            case let .categorySelected(category):
                state.selectedCategory = category
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

