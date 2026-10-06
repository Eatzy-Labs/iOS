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
        var isDietaryPreferencePresented = false
        var profile: ProfileFeature.State
        var dietaryPreference: DietaryPreferenceFeature.State
        var me: MeResponseDTO?
        var countries: [CountryDTO] = []
        var isCountriesLoading = false
        var countriesErrorMessage: String?
        var isProfileLoading = false
        var profileErrorMessage: String?
        var isLogoutAlertPresented = false
        var isLoggingOut = false
        var logoutErrorMessage: String?

        init(isAuthenticated: Bool, universityCode: String = "") {
            self.isAuthenticated = isAuthenticated

            var initialProfile = ProfileMockData.profile
            if !universityCode.isEmpty {
                initialProfile.university = universityCode.uppercased()
            }
            profile = ProfileFeature.State(profile: initialProfile)
            dietaryPreference = DietaryPreferenceFeature.State(
                isAuthenticated: isAuthenticated
            )
        }
    }

    @CasePathable
    enum Action {
        case viewAppeared
        case profileResponse(Result<MeResponseDTO, NetworkError>)
        case countriesResponse(Result<CountriesResponseDTO, NetworkError>)
        case backButtonTapped
        case loginButtonTapped
        case logoutButtonTapped
        case logoutAlertPresentationChanged(Bool)
        case logoutConfirmed
        case logoutResponse(Result<Void, NetworkError>)
        case logoutErrorDismissed
        case profileCardTapped
        case dietaryPreferenceTapped
        case profile(ProfileFeature.Action)
        case dietaryPreference(DietaryPreferenceFeature.Action)
        case delegate(Delegate)

        enum Delegate {
            case backRequested
            case loginRequired
            case logoutCompleted
        }
    }

    @Dependency(\.usersClient) private var usersClient
    @Dependency(\.catalogClient) private var catalogClient
    @Dependency(\.logoutClient) private var logoutClient

    var body: some Reducer<State, Action> {
        Scope(state: \.profile, action: \.profile) {
            ProfileFeature()
        }

        Scope(state: \.dietaryPreference, action: \.dietaryPreference) {
            DietaryPreferenceFeature()
        }

        Reduce { state, action in
            switch action {
            case .viewAppeared:
                guard state.isAuthenticated else {
                    return .none
                }

                var effects: [Effect<Action>] = []

                if state.me == nil, !state.isProfileLoading {
                    state.isProfileLoading = true
                    state.profileErrorMessage = nil
                    effects.append(
                        .run { send in
                            do {
                                await send(
                                    .profileResponse(.success(try await usersClient.fetchMe()))
                                )
                            } catch {
                                await send(
                                    .profileResponse(
                                        .failure(error as? NetworkError ?? .unknownError)
                                    )
                                )
                            }
                        }
                    )
                }

                if state.countries.isEmpty, !state.isCountriesLoading {
                    state.isCountriesLoading = true
                    state.countriesErrorMessage = nil
                    effects.append(
                        .run { send in
                            do {
                                await send(
                                    .countriesResponse(
                                        .success(try await catalogClient.fetchCountries("en"))
                                    )
                                )
                            } catch {
                                await send(
                                    .countriesResponse(
                                        .failure(error as? NetworkError ?? .unknownError)
                                    )
                                )
                            }
                        }
                    )
                }

                return .merge(effects)

            case let .profileResponse(.success(response)):
                state.isProfileLoading = false
                state.me = response
                state.profileErrorMessage = nil

                let profile = Profile(
                    userID: response.profileId ?? response.nickname ?? response.id,
                    email: response.email,
                    university: state.profile.profile.university,
                    country: countryName(for: response.nationality, in: state.countries),
                    imageData: state.profile.profile.imageData
                )
                state.profile.profile = profile
                state.profile.draft = profile
                state.profile.nationalityCode = response.nationality
                state.profile.draftNationalityCode = response.nationality
                return .none

            case let .profileResponse(.failure(error)):
                state.isProfileLoading = false
                state.profileErrorMessage = error.description
                return .none

            case let .countriesResponse(.success(response)):
                state.isCountriesLoading = false
                state.countriesErrorMessage = nil
                state.countries = response.countries
                state.profile.countries = response.countries

                if let me = state.me {
                    let country = countryName(for: me.nationality, in: response.countries)
                    state.profile.profile.country = country
                    state.profile.draft.country = country
                    state.profile.nationalityCode = me.nationality
                    state.profile.draftNationalityCode = me.nationality
                }
                return .none

            case let .countriesResponse(.failure(error)):
                state.isCountriesLoading = false
                state.countriesErrorMessage = error.description
                return .none

            case .backButtonTapped:
                return .send(.delegate(.backRequested))

            case .loginButtonTapped:
                return .send(.delegate(.loginRequired))

            case .logoutButtonTapped:
                state.isLogoutAlertPresented = true
                return .none

            case let .logoutAlertPresentationChanged(isPresented):
                state.isLogoutAlertPresented = isPresented
                return .none

            case .logoutConfirmed:
                state.isLogoutAlertPresented = false
                guard !state.isLoggingOut else { return .none }
                state.isLoggingOut = true
                state.logoutErrorMessage = nil
                return .run { send in
                    do {
                        try await logoutClient.logout()
                        await send(.logoutResponse(.success(())))
                    } catch {
                        await send(
                            .logoutResponse(
                                .failure(error as? NetworkError ?? .unknownError)
                            )
                        )
                    }
                }

            case .logoutResponse(.success):
                state.isLoggingOut = false
                return .send(.delegate(.logoutCompleted))

            case let .logoutResponse(.failure(error)):
                state.isLoggingOut = false
                state.logoutErrorMessage = error.description
                return .none

            case .logoutErrorDismissed:
                state.logoutErrorMessage = nil
                return .none

            case .profileCardTapped:
                state.isProfilePresented = true
                return .none

            case .dietaryPreferenceTapped:
                state.isDietaryPreferencePresented = true
                return .none

            case .profile(.delegate(.backRequested)):
                state.isProfilePresented = false
                return .none

            case let .profile(.delegate(.profileUpdated(response))):
                state.me = response
                return .none

            case .profile:
                return .none

            case .dietaryPreference(.delegate(.backRequested)):
                state.isDietaryPreferencePresented = false
                return .none

            case .dietaryPreference:
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private func countryName(for code: String, in countries: [CountryDTO]) -> String {
        countries.first(where: { $0.code == code })?.name ?? code
    }
}
