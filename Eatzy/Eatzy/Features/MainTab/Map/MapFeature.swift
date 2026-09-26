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
        var isPlaceSheetPresented = false
        var placeSheet = MapPlaceSheetFeature.State()

        var visiblePlaces: [MapPlace] {
            guard selectedCategory != .all else {
                return places
            }

            return places.filter { $0.category == selectedCategory }
        }
    }

    @CasePathable
    enum Action {
        case viewAppeared
        case universityButtonTapped
        case settingButtonTapped
        case categorySelected(MapPlace.Category)
        case markerTapped(MapPlace.ID)
        case placeSheetPresentationChanged(Bool)
        case placeSheet(MapPlaceSheetFeature.Action)
        case delegate(Delegate)

        enum Delegate {
            case settingRequested
        }
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.placeSheet, action: \.placeSheet) {
            MapPlaceSheetFeature()
        }

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

            case let .markerTapped(placeID):
                state.placeSheet.place = state.places.first { $0.id == placeID }
                state.isPlaceSheetPresented = state.placeSheet.place != nil
                return .none

            case let .placeSheetPresentationChanged(isPresented):
                state.isPlaceSheetPresented = isPresented
                return .none

            case .placeSheet(.delegate(.dismissRequested)):
                state.isPlaceSheetPresented = false
                return .none

            case .placeSheet:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
