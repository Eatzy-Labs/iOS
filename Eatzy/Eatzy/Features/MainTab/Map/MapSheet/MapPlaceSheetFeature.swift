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
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .menuButtonTapped:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
