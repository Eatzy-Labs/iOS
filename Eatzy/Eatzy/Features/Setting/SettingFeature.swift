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
        var profile: ProfileFeature.State
        var me: MeResponseDTO?
        var isProfileLoading = false
        var profileErrorMessage: String?

        init(isAuthenticated: Bool, universityCode: String = "") {
            self.isAuthenticated = isAuthenticated

            var initialProfile = ProfileMockData.profile
            if !universityCode.isEmpty {
                initialProfile.university = universityCode.uppercased()
            }
            profile = ProfileFeature.State(profile: initialProfile)
        }
    }

    @CasePathable
    enum Action {
        case viewAppeared
        case profileResponse(Result<MeResponseDTO, NetworkError>)
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

    @Dependency(\.usersClient) private var usersClient

    var body: some Reducer<State, Action> {
        Scope(state: \.profile, action: \.profile) {
            ProfileFeature()
        }

        Reduce { state, action in
            switch action {
            case .viewAppeared:
                guard state.isAuthenticated, state.me == nil, !state.isProfileLoading else {
                    return .none
                }

                state.isProfileLoading = true
                state.profileErrorMessage = nil
                return .run { send in
                    do {
                        await send(.profileResponse(.success(try await usersClient.fetchMe())))
                    } catch {
                        await send(
                            .profileResponse(
                                .failure(error as? NetworkError ?? .unknownError)
                            )
                        )
                    }
                }

            case let .profileResponse(.success(response)):
                state.isProfileLoading = false
                state.me = response
                state.profileErrorMessage = nil

                let profile = Profile(
                    userID: response.profileId ?? response.nickname ?? response.id,
                    email: response.email,
                    university: state.profile.profile.university,
                    country: OnboardingSignUpMetadata.nationalityName(
                        for: response.nationality
                    ),
                    imageData: state.profile.profile.imageData
                )
                state.profile.profile = profile
                state.profile.draft = profile
                return .none

            case let .profileResponse(.failure(error)):
                state.isProfileLoading = false
                state.profileErrorMessage = error.description
                return .none

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

            case let .profile(.delegate(.profileUpdated(response))):
                state.me = response
                return .none

            case .profile:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
