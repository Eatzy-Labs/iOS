//
//  RootFeature.swift
//  Eatzy
//

import ComposableArchitecture

struct RootFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        enum Route: Equatable {
            case splash
            case login
        }

        var route: Route = .splash
        var login = LoginFeature.State()
    }

    @CasePathable
    enum Action {
        case splashTask
        case splashFinished
        case login(LoginFeature.Action)
    }

    @Dependency(\.continuousClock) private var clock

    nonisolated private enum CancelID: Hashable, Sendable {
        case splashDelay
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .splashTask:
            return .run { send in
                try await clock.sleep(for: .seconds(2))
                await send(.splashFinished)
            }
            .cancellable(id: CancelID.splashDelay, cancelInFlight: true)

        case .splashFinished:
            state.route = .login
            return .none

        case let .login(loginAction):
            return LoginFeature()
                .reduce(into: &state.login, action: loginAction)
                .map(Action.login)
        }
    }
}
