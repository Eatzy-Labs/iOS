//
//  ProfileFeature.swift
//  Eatzy
//

import ComposableArchitecture
import Foundation

struct ProfileFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var isEditing = false
        var profile: Profile
        var draft: Profile
        var universities: [String]
        var countries: [CountryDTO]
        var nationalityCode: String
        var draftNationalityCode: String
        var idFieldState = EatzyTextfield.State.writing
        var emailFieldState = EatzyTextfield.State.writing
        var isPhotoPickerPresented = false
        var isCountryDropdownExpanded = false
        var isDiscardAlertPresented = false
        var isSaving = false
        var saveErrorMessage: String?

        init(
            profile: Profile = ProfileMockData.profile,
            universities: [String] = ProfileMockData.universities,
            countries: [CountryDTO] = []
        ) {
            self.profile = profile
            self.draft = profile
            self.universities = universities
            self.countries = countries
            self.nationalityCode = ""
            self.draftNationalityCode = ""
        }
    }

    enum Action {
        case backButtonTapped
        case editButtonTapped
        case doneButtonTapped
        case updateProfileResponse(Result<MeResponseDTO, NetworkError>)
        case saveErrorDismissed
        case userIDChanged(String)
        case idFieldStateChanged(EatzyTextfield.State)
        case emailChanged(String)
        case emailFieldStateChanged(EatzyTextfield.State)
        case universitySelectionChanged(Set<String>)
        case countrySelectionChanged(Set<String>)
        case profileImageTapped
        case photoPickerPresentationChanged(Bool)
        case profileImageDataLoaded(Data?)
        case countryDropdownExpansionChanged(Bool)
        case discardAlertPresentationChanged(Bool)
        case discardChangesButtonTapped
        case cancelDiscardButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case backRequested
            case profileUpdated(MeResponseDTO)
        }
    }

    @Dependency(\.usersClient) private var usersClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                guard !state.isEditing else {
                    state.isDiscardAlertPresented = true
                    return .none
                }
                return .send(.delegate(.backRequested))

            case .editButtonTapped:
                state.draft = state.profile
                state.draftNationalityCode = state.nationalityCode
                state.isEditing = true
                return .none

            case .doneButtonTapped:
                guard !state.isSaving else { return .none }
                state.idFieldState = idValidationState(for: state.draft.userID)
                state.emailFieldState = emailValidationState(for: state.draft.email)

                guard case .writing = state.idFieldState,
                      case .writing = state.emailFieldState else {
                    return .none
                }

                state.isSaving = true
                state.saveErrorMessage = nil
                let request = UpdateProfileRequestDTO(
                    nationality: state.draftNationalityCode,
                    profileId: state.draft.userID
                )
                return .run { send in
                    do {
                        await send(
                            .updateProfileResponse(
                                .success(try await usersClient.updateProfile(request))
                            )
                        )
                    } catch {
                        await send(
                            .updateProfileResponse(
                                .failure(error as? NetworkError ?? .unknownError)
                            )
                        )
                    }
                }

            case let .updateProfileResponse(.success(response)):
                state.isSaving = false
                state.saveErrorMessage = nil
                state.nationalityCode = response.nationality
                state.draftNationalityCode = response.nationality
                let profile = Profile(
                    userID: response.profileId ?? response.nickname ?? response.id,
                    email: response.email,
                    university: state.profile.university,
                    country: countryName(for: response.nationality, in: state.countries),
                    imageData: state.profile.imageData
                )
                state.profile = profile
                state.draft = profile
                state.isEditing = false
                return .send(.delegate(.profileUpdated(response)))

            case let .updateProfileResponse(.failure(error)):
                state.isSaving = false
                state.saveErrorMessage = error.description
                return .none

            case .saveErrorDismissed:
                state.saveErrorMessage = nil
                return .none

            case let .userIDChanged(userID):
                state.draft.userID = userID
                state.idFieldState = idValidationState(for: userID)
                return .none

            case let .idFieldStateChanged(fieldState):
                state.idFieldState = fieldState
                return .none

            case let .emailChanged(email):
                state.draft.email = email
                state.emailFieldState = emailValidationState(for: email)
                return .none

            case let .emailFieldStateChanged(fieldState):
                state.emailFieldState = fieldState
                return .none

            case let .universitySelectionChanged(selection):
                if let university = singleSelection(
                    from: selection,
                    previous: [state.draft.university]
                ).first {
                    state.draft.university = university
                }
                return .none

            case let .countrySelectionChanged(selection):
                if let country = singleSelection(
                    from: selection,
                    previous: [state.draftNationalityCode]
                ).first {
                    state.draftNationalityCode = country
                    state.draft.country = countryName(for: country, in: state.countries)
                }
                return .none

            case .profileImageTapped:
                state.isPhotoPickerPresented = true
                return .none

            case let .photoPickerPresentationChanged(isPresented):
                state.isPhotoPickerPresented = isPresented
                return .none

            case let .profileImageDataLoaded(data):
                state.draft.imageData = data
                state.isPhotoPickerPresented = false
                return .none

            case let .countryDropdownExpansionChanged(isExpanded):
                state.isCountryDropdownExpanded = isExpanded
                return .none

            case let .discardAlertPresentationChanged(isPresented):
                state.isDiscardAlertPresented = isPresented
                return .none

            case .cancelDiscardButtonTapped:
                state.isDiscardAlertPresented = false
                return .none

            case .discardChangesButtonTapped:
                state.draft = state.profile
                state.draftNationalityCode = state.nationalityCode
                state.idFieldState = .writing
                state.emailFieldState = .writing
                state.isDiscardAlertPresented = false
                state.isEditing = false
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private func idValidationState(for userID: String) -> EatzyTextfield.State {
        guard userID.count >= 4 else {
            return .error(message: "Enter at least 4 characters")
        }

        guard userID.containsOnlyLettersAndNumbers else {
            return .error(message: "Use only letters and number")
        }

        return .writing
    }

    private func emailValidationState(for email: String) -> EatzyTextfield.State {
        email.isValidEmail
            ? .writing
            : .error(message: "Enter a valid email")
    }

    private func singleSelection(
        from selection: Set<String>,
        previous: Set<String>
    ) -> Set<String> {
        if let newlySelected = selection.subtracting(previous).first {
            return [newlySelected]
        }

        return selection.first.map { [$0] } ?? []
    }

    private func countryName(for code: String, in countries: [CountryDTO]) -> String {
        countries.first(where: { $0.code == code })?.name ?? code
    }
}
