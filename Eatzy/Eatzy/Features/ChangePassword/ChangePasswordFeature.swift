//
//  ChangePasswordFeature.swift
//  Eatzy
//
//  Created by sun on 10/11/26.
//

import ComposableArchitecture

struct ChangePasswordFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        enum Step: Equatable {
            case currentPassword
            case newPassword
        }

        var step: Step = .currentPassword
        var currentPassword = ""
        var currentPasswordFieldState = EatzyTextfield.State.placeholder
        var newPassword = ""
        var newPasswordFieldState = EatzyTextfield.State.placeholder
        var isNewPasswordValidated = false
        var confirmedPassword = ""
        var confirmedPasswordFieldState = EatzyTextfield.State.placeholder

        var showsPasswordConfirmation: Bool {
            isNewPasswordValidated
        }

        var canConfirm: Bool {
            isNewPasswordValidated &&
                !confirmedPassword.isEmpty &&
                newPassword == confirmedPassword
        }
    }

    enum Action {
        case backButtonTapped
        case currentPasswordChanged(String)
        case currentPasswordFieldStateChanged(EatzyTextfield.State)
        case currentPasswordSubmitted
        case newPasswordChanged(String)
        case newPasswordFieldStateChanged(EatzyTextfield.State)
        case newPasswordSubmitted
        case confirmedPasswordChanged(String)
        case confirmedPasswordFieldStateChanged(EatzyTextfield.State)
        case confirmedPasswordFocusChanged(Bool)
        case confirmButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case backRequested
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                if state.step == .newPassword {
                    state.step = .currentPassword
                    state.newPassword = ""
                    state.newPasswordFieldState = .placeholder
                    state.isNewPasswordValidated = false
                    state.confirmedPassword = ""
                    state.confirmedPasswordFieldState = .placeholder
                    return .none
                }
                return .send(.delegate(.backRequested))

            case let .currentPasswordChanged(password):
                state.currentPassword = password
                state.currentPasswordFieldState = password.isEmpty ? .placeholder : .writing
                return .none

            case let .currentPasswordFieldStateChanged(fieldState):
                state.currentPasswordFieldState = fieldState
                return .none

            case .currentPasswordSubmitted:
                guard !state.currentPassword.isEmpty else { return .none }
                state.currentPasswordFieldState = .filled
                state.step = .newPassword
                return .none

            case let .newPasswordChanged(password):
                state.newPassword = password
                state.isNewPasswordValidated = false
                state.newPasswordFieldState = password.isEmpty ? .placeholder : .writing
                state.confirmedPassword = ""
                state.confirmedPasswordFieldState = .placeholder
                return .none

            case let .newPasswordFieldStateChanged(fieldState):
                state.newPasswordFieldState = fieldState
                return .none

            case .newPasswordSubmitted:
                if let message = state.newPassword.passwordValidationErrorMessage {
                    state.newPasswordFieldState = .error(message: message)
                    state.isNewPasswordValidated = false
                } else {
                    state.newPasswordFieldState = .filled
                    state.isNewPasswordValidated = true
                }
                return .none

            case let .confirmedPasswordChanged(password):
                state.confirmedPassword = password
                state.confirmedPasswordFieldState = password.isEmpty ? .placeholder : .writing
                return .none

            case let .confirmedPasswordFieldStateChanged(fieldState):
                state.confirmedPasswordFieldState = fieldState
                return .none

            case let .confirmedPasswordFocusChanged(isFocused):
                guard !isFocused, !state.confirmedPassword.isEmpty else { return .none }
                state.confirmedPasswordFieldState = state.confirmedPassword == state.newPassword
                    ? .filled
                    : .error(message: "Passwords don’t match")
                return .none

            case .confirmButtonTapped:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
