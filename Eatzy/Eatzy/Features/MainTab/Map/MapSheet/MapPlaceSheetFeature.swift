//
//  MapPlaceSheetFeature.swift
//  Eatzy
//

import ComposableArchitecture

struct MapPlaceSheetFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var place: MapPlace?

        init(place: MapPlace? = nil) {
            self.place = place
        }
    }

    enum Action {
        case menuButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case dismissRequested
            case menuRequested(cafeteriaCode: String)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .menuButtonTapped:
                guard
                    state.place?.hasMenu == true,
                    let cafeteriaCode = state.place?.cafeteriaCode,
                    !cafeteriaCode.isEmpty
                else {
                    return .none
                }
                return .send(.delegate(.menuRequested(cafeteriaCode: cafeteriaCode)))

            case .delegate:
                return .none
            }
        }
    }
}
