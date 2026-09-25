//
//  ProfileFeature.swift
//  Eatzy
//

import ComposableArchitecture
import Foundation

struct ProfileFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        struct Snapshot: Equatable {
            let userID: String
            let email: String
            let selectedUniversity: Set<String>
            let selectedCountry: Set<String>
            let profileImageData: Data?
        }

        var isEditing = false
        var userID = "happypibi1122"
        var email = "aaaa@aaaa.com"
        var idFieldState = EatzyTextfield.State.writing
        var emailFieldState = EatzyTextfield.State.writing
        var selectedUniversity: Set<String> = ["POSTECH"]
        var selectedCountry: Set<String> = ["Korea"]
        var profileImageData: Data?
        var isPhotoPickerPresented = false
        var isCountryDropdownExpanded = false
        var isDiscardAlertPresented = false
        var editSnapshot: Snapshot?
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
                state.editSnapshot = State.Snapshot(
                    userID: state.userID,
                    email: state.email,
                    selectedUniversity: state.selectedUniversity,
                    selectedCountry: state.selectedCountry,
                    profileImageData: state.profileImageData
                )
                state.isEditing = true
                return .none

            case .doneButtonTapped:
                state.idFieldState = idValidationState(for: state.userID)
                state.emailFieldState = emailValidationState(for: state.email)

                guard case .writing = state.idFieldState,
                      case .writing = state.emailFieldState else {
                    return .none
                }

                state.isEditing = false
                state.editSnapshot = nil
                return .none

            case let .userIDChanged(userID):
                state.userID = userID
                state.idFieldState = idValidationState(for: userID)
                return .none

            case let .idFieldStateChanged(fieldState):
                state.idFieldState = fieldState
                return .none

            case let .emailChanged(email):
                state.email = email
                state.emailFieldState = emailValidationState(for: email)
                return .none

            case let .emailFieldStateChanged(fieldState):
                state.emailFieldState = fieldState
                return .none

            case let .universitySelectionChanged(selection):
                state.selectedUniversity = singleSelection(
                    from: selection,
                    previous: state.selectedUniversity
                )
                return .none

            case let .countrySelectionChanged(selection):
                state.selectedCountry = singleSelection(
                    from: selection,
                    previous: state.selectedCountry
                )
                return .none

            case .profileImageTapped:
                state.isPhotoPickerPresented = true
                return .none

            case let .photoPickerPresentationChanged(isPresented):
                state.isPhotoPickerPresented = isPresented
                return .none

            case let .profileImageDataLoaded(data):
                state.profileImageData = data
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
                if let snapshot = state.editSnapshot {
                    state.userID = snapshot.userID
                    state.email = snapshot.email
                    state.selectedUniversity = snapshot.selectedUniversity
                    state.selectedCountry = snapshot.selectedCountry
                    state.profileImageData = snapshot.profileImageData
                }

                state.idFieldState = .writing
                state.emailFieldState = .writing
                state.isDiscardAlertPresented = false
                state.isEditing = false
                state.editSnapshot = nil
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
