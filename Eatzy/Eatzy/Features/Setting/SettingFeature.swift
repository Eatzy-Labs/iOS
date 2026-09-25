//
//  SettingFeature.swift
//  Eatzy
//

import ComposableArchitecture

struct SettingFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var isAuthenticated: Bool
        var isProfilePresented = false
        var profile = ProfileFeature.State()
    }

    @CasePathable
    enum Action {
        case backButtonTapped
        case loginButtonTapped
        case profileCardTapped
        case profile(ProfileFeature.Action)
        case delegate(Delegate)

        enum Delegate {
            case backRequested
            case loginRequired
        }
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.profile, action: \.profile) {
            ProfileFeature()
        }

        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .send(.delegate(.backRequested))

            case .loginButtonTapped:
                return .send(.delegate(.loginRequired))

            case .profileCardTapped:
                state.isProfilePresented = true
                return .none

            case .profile(.delegate(.backRequested)):
                state.isProfilePresented = false
                return .none

            case .profile:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
