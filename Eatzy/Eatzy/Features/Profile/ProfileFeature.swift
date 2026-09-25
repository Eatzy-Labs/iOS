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
        var countries: [String]
        var idFieldState = EatzyTextfield.State.writing
        var emailFieldState = EatzyTextfield.State.writing
        var isPhotoPickerPresented = false
        var isCountryDropdownExpanded = false
        var isDiscardAlertPresented = false

        init(
            profile: Profile = ProfileMockData.profile,
            universities: [String] = ProfileMockData.universities,
            countries: [String] = ProfileMockData.countries
        ) {
            self.profile = profile
            self.draft = profile
            self.universities = universities
            self.countries = countries
        }
    }

    enum Action {
        case backButtonTapped
        case editButtonTapped
        case doneButtonTapped
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
        case profileLoaded(
            profile: Profile,
            universities: [String],
            countries: [String]
        )
        case discardAlertPresentationChanged(Bool)
        case discardChangesButtonTapped
        case cancelDiscardButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case backRequested
        }
    }

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
                state.isEditing = true
                return .none

            case .doneButtonTapped:
                state.idFieldState = idValidationState(for: state.draft.userID)
                state.emailFieldState = emailValidationState(for: state.draft.email)

                guard case .writing = state.idFieldState,
                      case .writing = state.emailFieldState else {
                    return .none
                }

                state.profile = state.draft
                state.isEditing = false
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
                    previous: [state.draft.country]
                ).first {
                    state.draft.country = country
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

            case let .profileLoaded(profile, universities, countries):
                state.profile = profile
                state.draft = profile
                state.universities = universities
                state.countries = countries
                return .none

            case let .discardAlertPresentationChanged(isPresented):
                state.isDiscardAlertPresented = isPresented
                return .none

            case .cancelDiscardButtonTapped:
                state.isDiscardAlertPresented = false
                return .none

            case .discardChangesButtonTapped:
                state.draft = state.profile
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
}
