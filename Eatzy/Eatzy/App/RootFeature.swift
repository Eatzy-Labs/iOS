//
//  RootFeature.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture

struct RootFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        enum Route: Equatable {
            case splash
            case login
            case onboarding
            case signUp
            case mainTab
        }

        var route: Route = .splash
        var login = LoginFeature.State()
        var onboarding = OnboardingFeature.State()
        var signUp = SignUpFeature.State()
        var mainTab = MainTabFeature.State()
    }

    @CasePathable
    enum Action {
        case splashTask
        case splashFinished
        case login(LoginFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case signUp(SignUpFeature.Action)
        case mainTab(MainTabFeature.Action)
    }

    @Dependency(\.continuousClock) private var clock

    nonisolated private enum CancelID: Hashable, Sendable {
        case splashDelay
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }

        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }

        Scope(state: \.signUp, action: \.signUp) {
            SignUpFeature()
        }

        Scope(state: \.mainTab, action: \.mainTab) {
            MainTabFeature()
        }

        Reduce { state, action in
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

            case .login(.signUpButtonTapped):
                state.onboarding = OnboardingFeature.State(entryPoint: .signUp)
                state.route = .onboarding
                return .none

            case .login(.guestButtonTapped):
                state.onboarding = OnboardingFeature.State(entryPoint: .guest)
                state.route = .onboarding
                return .none

            case .login(.loginButtonTapped):
                state.mainTab = MainTabFeature.State(isAuthenticated: true)
                state.route = .mainTab
                return .none

            case .login:
                return .none

            case .onboarding(.delegate(.backToLogin)):
                state.route = .login
                return .none

            case .onboarding(.delegate(.onboardingCompleted)):
                guard state.onboarding.entryPoint == .signUp else {
                    state.mainTab = MainTabFeature.State(isAuthenticated: false)
                    state.route = .mainTab
                    return .none
                }
                state.signUp = SignUpFeature.State()
                state.route = .signUp
                return .none

            case .signUp(.delegate(.backToOnboarding)):
                state.route = .onboarding
                return .none

            case .onboarding:
                return .none

            case .signUp(.delegate(.signUpCompleted)):
                state.mainTab = MainTabFeature.State(isAuthenticated: true)
                state.route = .mainTab
                return .none

            case .signUp:
                return .none

            case .mainTab(.delegate(.loginRequired)):
                state.login = LoginFeature.State()
                state.route = .login
                return .none

            case .mainTab:
                return .none
            }
        }
    }
}
