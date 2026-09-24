//
//  MainTabFeature.swift
//  Eatzy
//

import ComposableArchitecture

struct MainTabFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        enum Tab: Hashable {
            case menu
            case map
        }

        var selectedTab: Tab = .menu
    }

    enum Action {
        case tabSelected(State.Tab)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            }
        }
    }
}
