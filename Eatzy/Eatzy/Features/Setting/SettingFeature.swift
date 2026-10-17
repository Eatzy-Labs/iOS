//
//  SettingFeature.swift
//  Eatzy
//

import ComposableArchitecture
import Foundation

struct SettingFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var isAuthenticated: Bool
        var isProfilePresented = false
        var isDietaryPreferencePresented = false
        var isDeleteAccountPresented = false
        var isChangePasswordPresented = false
        var profile: ProfileFeature.State
        var dietaryPreference: DietaryPreferenceFeature.State
        var deleteAccount = DeleteAccountFeature.State()
        var changePassword = ChangePasswordFeature.State()
        var me: MeResponseDTO?
        var countries: [CountryDTO] = []
        var isCountriesLoading = false
        var countriesErrorMessage: String?
        var universities: [CatalogUniversityDTO] = []
        var isUniversitiesLoading = false
        var universitiesErrorMessage: String?
        var isProfileLoading = false
        var profileErrorMessage: String?
        var isLogoutAlertPresented = false
        var isLoggingOut = false
        var logoutErrorMessage: String?
        var legalDocuments: LegalDocumentsResponseDTO?
        var isLegalDocumentsLoading = false
        var legalDocumentsErrorMessage: String?
        var selectedLegalDocumentURL: URL?
        var isLegalDocumentPresented = false

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
        case universitiesResponse(Result<CatalogResponseDTO, NetworkError>)
        case legalDocumentsResponse(Result<LegalDocumentsResponseDTO, NetworkError>)
        case legalDocumentTapped(String?)
        case legalDocumentDismissed
        case backButtonTapped
        case loginButtonTapped
        case logoutButtonTapped
        case logoutAlertPresentationChanged(Bool)
        case logoutConfirmed
        case logoutResponse(Result<Void, NetworkError>)
        case logoutErrorDismissed
        case profileCardTapped
        case dietaryPreferenceTapped
        case deleteAccountTapped
        case changePasswordTapped
        case profile(ProfileFeature.Action)
        case dietaryPreference(DietaryPreferenceFeature.Action)
        case deleteAccount(DeleteAccountFeature.Action)
        case changePassword(ChangePasswordFeature.Action)
        case delegate(Delegate)

        enum Delegate {
            case backRequested
            case loginRequired
            case logoutCompleted
            case deleteAccountCompleted
            case universityChanged(code: String, name: String)
        }
    }

    @Dependency(\.usersClient) private var usersClient
    @Dependency(\.catalogClient) private var catalogClient
    @Dependency(\.logoutClient) private var logoutClient
    @Dependency(\.legalDocumentsClient) private var legalDocumentsClient

    var body: some Reducer<State, Action> {
        Scope(state: \.profile, action: \.profile) {
            ProfileFeature()
        }

        Scope(state: \.dietaryPreference, action: \.dietaryPreference) {
            DietaryPreferenceFeature()
        }

        Scope(state: \.deleteAccount, action: \.deleteAccount) {
            DeleteAccountFeature()
        }

        Scope(state: \.changePassword, action: \.changePassword) {
            ChangePasswordFeature()
        }

        Reduce { state, action in
            switch action {
            case .viewAppeared:
                var effects: [Effect<Action>] = []

                if state.legalDocuments == nil, !state.isLegalDocumentsLoading {
                    state.isLegalDocumentsLoading = true
                    state.legalDocumentsErrorMessage = nil
                    effects.append(
                        .run { send in
                            do {
                                await send(
                                    .legalDocumentsResponse(
                                        .success(try await legalDocumentsClient.fetch())
                                    )
                                )
                            } catch {
                                await send(
                                    .legalDocumentsResponse(
                                        .failure(error as? NetworkError ?? .unknownError)
                                    )
                                )
                            }
                        }
                    )
                }

                guard state.isAuthenticated else {
                    return .merge(effects)
                }

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

                if state.universities.isEmpty, !state.isUniversitiesLoading {
                    state.isUniversitiesLoading = true
                    state.universitiesErrorMessage = nil
                    effects.append(
                        .run { send in
                            do {
                                await send(
                                    .universitiesResponse(
                                        .success(try await catalogClient.fetch("en"))
                                    )
                                )
                            } catch {
                                await send(
                                    .universitiesResponse(
                                        .failure(error as? NetworkError ?? .unknownError)
                                    )
                                )
                            }
                        }
                    )
                }

                return .merge(effects)

            case let .legalDocumentsResponse(.success(response)):
                state.isLegalDocumentsLoading = false
                state.legalDocumentsErrorMessage = nil
                state.legalDocuments = response
                return .none

            case let .legalDocumentsResponse(.failure(error)):
                state.isLegalDocumentsLoading = false
                state.legalDocumentsErrorMessage = error.description
                return .none

            case let .legalDocumentTapped(urlString):
                state.selectedLegalDocumentURL = urlString.flatMap(URL.init(string:))
                state.isLegalDocumentPresented = true
                return .none

            case .legalDocumentDismissed:
                state.selectedLegalDocumentURL = nil
                state.isLegalDocumentPresented = false
                return .none

            case let .profileResponse(.success(response)):
                state.isProfileLoading = false
                state.me = response
                state.profileErrorMessage = nil

                let universityCode = response.universityCode ?? ""
                let profile = Profile(
                    userID: response.profileId ?? response.nickname ?? response.id,
                    email: response.email,
                    university: universityName(
                        for: universityCode,
                        in: state.universities,
                        fallback: state.profile.profile.university
                    ),
                    country: countryName(for: response.nationality, in: state.countries),
                    imageData: state.profile.profile.imageData
                )
                state.profile.profile = profile
                state.profile.draft = profile
                state.profile.universityCode = universityCode
                state.profile.draftUniversityCode = universityCode
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

            case let .universitiesResponse(.success(response)):
                state.isUniversitiesLoading = false
                state.universitiesErrorMessage = nil
                state.universities = response.universities
                state.profile.universities = response.universities

                if let universityCode = state.me?.universityCode {
                    let university = universityName(
                        for: universityCode,
                        in: response.universities,
                        fallback: universityCode.uppercased()
                    )
                    state.profile.profile.university = university
                    state.profile.draft.university = university
                    state.profile.universityCode = universityCode
                    state.profile.draftUniversityCode = universityCode
                }
                return .none

            case let .universitiesResponse(.failure(error)):
                state.isUniversitiesLoading = false
                state.universitiesErrorMessage = error.description
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

            case .deleteAccountTapped:
                state.deleteAccount = DeleteAccountFeature.State()
                state.isDeleteAccountPresented = true
                return .none

            case .changePasswordTapped:
                state.changePassword = ChangePasswordFeature.State()
                state.isChangePasswordPresented = true
                return .none

            case .profile(.delegate(.backRequested)):
                state.isProfilePresented = false
                return .none

            case let .profile(.delegate(.profileUpdated(response))):
                state.me = response
                guard let universityCode = response.universityCode else {
                    return .none
                }
                let universityName = universityName(
                    for: universityCode,
                    in: state.universities,
                    fallback: universityCode.uppercased()
                )
                return .send(
                    .delegate(
                        .universityChanged(
                            code: universityCode,
                            name: universityName
                        )
                    )
                )

            case .profile:
                return .none

            case .dietaryPreference(.delegate(.backRequested)):
                state.isDietaryPreferencePresented = false
                return .none

            case .dietaryPreference:
                return .none

            case .deleteAccount(.delegate(.backRequested)):
                state.isDeleteAccountPresented = false
                return .none

            case .deleteAccount(.delegate(.deleteAccountCompleted)):
                state.isDeleteAccountPresented = false
                return .send(.delegate(.deleteAccountCompleted))

            case .deleteAccount:
                return .none

            case .changePassword(.delegate(.backRequested)):
                state.isChangePasswordPresented = false
                return .none

            case .changePassword(.delegate(.passwordChanged)):
                state.isChangePasswordPresented = false
                return .none

            case .changePassword:
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private func countryName(for code: String, in countries: [CountryDTO]) -> String {
        countries.first(where: { $0.code == code })?.name ?? code
    }

    private func universityName(
        for code: String,
        in universities: [CatalogUniversityDTO],
        fallback: String
    ) -> String {
        guard !code.isEmpty else { return fallback }
        let university = universities.first(where: { $0.code == code })
        return university?.name ?? university?.nameEn ?? fallback
    }
}
