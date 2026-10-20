//
//  RootFeature.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import Foundation

struct RootFeature: Reducer {
    enum UpdateAlert: Equatable {
        case required
        case recommended
    }

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
        var updateAlert: UpdateAlert?
        var appStoreURL: URL?
    }

    @CasePathable
    enum Action {
        case splashTask
        case splashFinished(
            isAuthenticated: Bool,
            universityCode: String?,
            versionRequirement: VersionRequirementResponseDTO?
        )
        case authenticatedUserLoaded(String?)
        case updateAlertDismissed
        case login(LoginFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case signUp(SignUpFeature.Action)
        case mainTab(MainTabFeature.Action)
    }

    @Dependency(\.continuousClock) private var clock
    @Dependency(\.autoLoginClient) private var autoLoginClient
    @Dependency(\.appVersionClient) private var appVersionClient
    @Dependency(\.usersClient) private var usersClient

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
                    async let minimumSplashDuration: Void = clock.sleep(for: .seconds(2))
                    async let isAuthenticated = autoLoginClient.restoreSession()
                    async let versionRequirement = try? appVersionClient.fetchRequirement()

                    let authenticated = await isAuthenticated
                    let universityCode: String?
                    if authenticated {
                        let profile = try? await usersClient.fetchMe()
                        universityCode = profile?.universityCode
                    } else {
                        universityCode = nil
                    }

                    try await minimumSplashDuration
                    await send(
                        .splashFinished(
                            isAuthenticated: authenticated,
                            universityCode: universityCode,
                            versionRequirement: await versionRequirement
                        )
                    )
                }
                .cancellable(id: CancelID.splashDelay, cancelInFlight: true)

            case let .splashFinished(isAuthenticated, universityCode, versionRequirement):
                if isAuthenticated {
                    state.mainTab = MainTabFeature.State(
                        isAuthenticated: true,
                        universityCode: universityCode ?? ""
                    )
                    state.route = .mainTab
                } else {
                    state.login = LoginFeature.State()
                    state.route = .login
                }

                if let versionRequirement {
                    let currentBuild = appVersionClient.currentBuild()
                    if currentBuild < versionRequirement.minSupportedBuild {
                        state.updateAlert = .required
                    } else if currentBuild < versionRequirement.latestBuild {
                        state.updateAlert = .recommended
                    }
                    state.appStoreURL = appVersionClient.appStoreURL()
                }
                return .none

            case .updateAlertDismissed:
                guard state.updateAlert == .recommended else { return .none }
                state.updateAlert = nil
                return .none

            case .login(.signUpButtonTapped):
                state.onboarding = OnboardingFeature.State(entryPoint: .signUp)
                state.route = .onboarding
                return .none

            case .login(.guestButtonTapped):
                state.onboarding = OnboardingFeature.State(entryPoint: .guest)
                state.route = .onboarding
                return .none

            case .login(.delegate(.loginCompleted)):
                return .run { send in
                    let profile = try? await usersClient.fetchMe()
                    await send(.authenticatedUserLoaded(profile?.universityCode))
                }

            case let .authenticatedUserLoaded(universityCode):
                state.mainTab = MainTabFeature.State(
                    isAuthenticated: true,
                    universityCode: universityCode ?? ""
                )
                state.route = .mainTab
                return .none

            case .login:
                return .none

            case .onboarding(.delegate(.backToLogin)):
                state.route = .login
                return .none

            case .onboarding(.delegate(.onboardingCompleted)):
                guard state.onboarding.entryPoint == .signUp else {
                    state.mainTab = MainTabFeature.State(
                        isAuthenticated: false,
                        universityCode: state.onboarding.selectedUniversityCode ?? "",
                        dietaryProfile: state.onboarding.dietaryProfile,
                        dietaryTaxonomy: state.onboarding.taxonomy
                    )
                    state.route = .mainTab
                    return .none
                }
                guard
                    let universityCode = state.onboarding.selectedUniversityCode,
                    let nationality = state.onboarding.selectedNationalityCode
                else {
                    return .none
                }
                state.signUp = SignUpFeature.State(
                    universityCode: universityCode,
                    nationality: nationality,
                    dietaryProfile: state.onboarding.dietaryProfile
                )
                state.route = .signUp
                return .none

            case .signUp(.delegate(.backToOnboarding)):
                state.route = .onboarding
                return .none

            case .onboarding:
                return .none

            case .signUp(.delegate(.signUpCompleted)):
                state.mainTab = MainTabFeature.State(
                    isAuthenticated: true,
                    universityCode: state.signUp.universityCode
                )
                state.route = .mainTab
                return .none

            case .signUp:
                return .none

            case .mainTab(.delegate(.loginRequired)):
                state.login = LoginFeature.State()
                state.route = .login
                return .none

            case .mainTab(.delegate(.logoutCompleted)):
                state.login = LoginFeature.State()
                state.mainTab = MainTabFeature.State(isAuthenticated: false)
                state.route = .login
                return .none

            case .mainTab(.delegate(.deleteAccountCompleted)):
                state.login = LoginFeature.State()
                state.mainTab = MainTabFeature.State(isAuthenticated: false)
                state.route = .login
                return .none

            case .mainTab:
                return .none
            }
        }
    }
}
