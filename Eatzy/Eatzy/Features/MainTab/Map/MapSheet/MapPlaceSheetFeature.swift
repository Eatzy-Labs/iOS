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
        case delegate(Delegate)

        enum Delegate {
            case dismissRequested
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .delegate:
                return .none
            }
        }
    }
}
