//
//  SettingFeature.swift
//  Eatzy
//

import ComposableArchitecture

struct SettingFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var isAuthenticated: Bool
    }

    enum Action {
        case backButtonTapped
        case loginButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case backRequested
            case loginRequired
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .backButtonTapped:
                return .send(.delegate(.backRequested))

            case .loginButtonTapped:
                return .send(.delegate(.loginRequired))

            case .delegate:
                return .none
            }
        }
    }
}

